# Определение пакетов и их зависимостей
packages = {
    "root": {
        "versions": ["1.0.0"],
        "dependencies": {
            "1.0.0": {
                "foo": "^1.0.0",
                "target": "^2.0.0"
            }
        }
    },
    "foo": {
        "versions": ["1.0.0", "1.1.0"],
        "dependencies": {
            "1.1.0": {
                "left": "^1.0.0",
                "right": "^1.0.0"
            },
            "1.0.0": {}
        }
    },
    "left": {
        "versions": ["1.0.0"],
        "dependencies": {
            "1.0.0": {
                "shared": ">=1.0.0"
            }
        }
    },
    "right": {
        "versions": ["1.0.0"],
        "dependencies": {
            "1.0.0": {
                "shared": "<2.0.0"
            }
        }
    },
    "shared": {
        "versions": ["1.0.0", "2.0.0"],
        "dependencies": {
            "1.0.0": {
                "target": "^1.0.0"
            },
            "2.0.0": {}
        }
    },
    "target": {
        "versions": ["1.0.0", "2.0.0"],
        "dependencies": {}
    }
}


def generate_minizinc_model(packages):
    package_names = list(packages.keys())
    version_names = {pkg: packages[pkg]["versions"] for pkg in package_names}

    # Генерация перечислений для пакетов и версий
    enum_packages = "enum Package = {" + ", ".join(package_names) + "};\n"
    enum_versions = "enum Version = {" + ", ".join(
        [f"v{v.replace('.', '_')}" for pkg in package_names for v in version_names[pkg]]) + "};\n"

    # Генерация массива версий для каждого пакета
    array_versions = "array[Package] of var Version: versions;\n"

    # Генерация ограничений на версии пакетов
    constraints = []
    for pkg in package_names:
        versions = version_names[pkg]
        constraints.append(
            f"constraint versions[{pkg}] = " + " \\/ ".join([f"v{v.replace('.', '_')}" for v in versions]) + ";\n")

    # Генерация ограничений на зависимости
    for pkg in package_names:
        for version, deps in packages[pkg]["dependencies"].items():
            if deps:
                version_constraint = f"versions[{pkg}] = v{version.replace('.', '_')}"
                for dep_pkg, dep_version in deps.items():
                    if dep_version.startswith("^"):
                        dep_version = dep_version[1:]
                        dep_versions = [v for v in version_names[dep_pkg] if v.startswith(dep_version)]
                    elif dep_version.startswith(">="):
                        dep_version = dep_version[2:]
                        dep_versions = [v for v in version_names[dep_pkg] if v >= dep_version]
                    elif dep_version.startswith("<"):
                        dep_version = dep_version[1:]
                        dep_versions = [v for v in version_names[dep_pkg] if v < dep_version]
                    else:
                        dep_versions = [dep_version]

                    dep_constraint = " \\/ ".join(
                        [f"versions[{dep_pkg}] = v{v.replace('.', '_')}" for v in dep_versions])
                    constraints.append(f"constraint {version_constraint} -> ({dep_constraint});\n")

    # Генерация решения и вывода
    solve_output = "solve satisfy;\n\noutput [\"root: \", show(versions[root]), \"\\n\",\n"
    for pkg in package_names[1:]:
        solve_output += f"        \"{pkg}: \", show(versions[{pkg}]), \"\\n\",\n"
    solve_output += "];\n"

    # Сборка всего вместе
    minizinc_model = enum_packages + enum_versions + array_versions + "".join(constraints) + solve_output
    return minizinc_model


# Генерация MiniZinc модели
minizinc_model = generate_minizinc_model(packages)
print(minizinc_model)
