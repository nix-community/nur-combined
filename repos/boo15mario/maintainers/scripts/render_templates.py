from jinja2 import Environment, FileSystemLoader
import os, yaml


def load_config(config_path="config.yml"):
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def render_all_templates(src_dir=".", config_path="config.yml"):
    context = load_config(config_path)
    env = Environment(loader=FileSystemLoader(src_dir))

    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith(".j2"):
                template_path = os.path.join(root, file)
                relative_template_path = os.path.relpath(template_path, src_dir)
                output_path = os.path.splitext(template_path)[0]  # strip .j2

                template = env.get_template(relative_template_path)
                rendered = template.render(context)

                with open(output_path, "w") as f:
                    f.write(rendered)


if __name__ == "__main__":
    render_all_templates()
