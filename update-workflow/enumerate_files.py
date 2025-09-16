import glob
import yaml

# Path to the data files and workflow file
data_files_pattern = "../data/*.in"
workflow_file_path = "../.github/workflows/test-schedule.yaml"

def get_data_files():
    """Enumerate all files matching the pattern."""
    return [file.split("/")[-1] for file in glob.glob(data_files_pattern)]

def update_workflow_file(files):
    """Update the workflow YAML file with the new list of files."""
    with open(workflow_file_path, "r") as f:
        workflow = yaml.safe_load(f)

    # Update the options list
    print(workflow)
    workflow[True]["workflow_dispatch"]["inputs"]["datafile"]["options"] = files

    with open(workflow_file_path, "w") as f:
        yaml.dump(workflow, f, sort_keys=False)

def main():
    files = get_data_files()
    update_workflow_file(files)
    print(f"Updated workflow file with options: {files}")

if __name__ == "__main__":
    main()
