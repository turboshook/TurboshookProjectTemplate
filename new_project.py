import shutil
import re
from pathlib import Path

def main():
    current_dir = Path.cwd()
    parent_dir = current_dir.parent
    script_path = Path(__file__).resolve()
    script_name = script_path.name
    project_name = input(" Hello! Enter a name for the new project: ").strip()

    if not project_name:
        print(" ! ERROR ! - Name cannot be empty.")
        return

    if not re.match(r'^[A-Za-z0-9 _-]+$', project_name):
        print(" ! ERROR ! - Directory name contains invalid characters.")
        print(" - Allowed: letters, numbers, spaces, hyphens (-), underscores (_)")
        return

    destination_dir = parent_dir / project_name

    if destination_dir.exists():
        print(f" ! ERROR ! - '{destination_dir}' already exists.")
        return

    def ignore(dirpath, filenames):
        ignore_list = {
            ".git",
            ".gitignore",
            ".gitattributes",
            script_name
        }
        return ignore_list.intersection(filenames)

    shutil.copytree(current_dir, destination_dir, ignore=ignore)

    print(f" - Successfully created sibling directory at: {destination_dir}")

    project_file = destination_dir / "project.godot"

    if project_file.exists():
        lines = project_file.read_text(encoding="utf-8").splitlines()
        new_lines = []

        for line in lines:
            if line.strip().startswith("config/name="):
                new_lines.append(f'config/name="{project_name}"')
            else:
                new_lines.append(line)

        project_file.write_text("\n".join(new_lines), encoding="utf-8")
        print(f" - Updated project name in project.godot to: {project_name}")
    else:
        print(" ! WARNING ! - project.godot not found in the copied directory.")

    print(" Successfully copied project template. Have fun!")

if __name__ == "__main__":
    main()