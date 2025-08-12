# Switch2OSM

Here is a re-work of <https://switch2osm.org> website using [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

The goal is to add to the site the ability to have instructions in different languages in one place.

## Contribution

You are welcome to extend the styling and content, add new languages. To do this, clone this repository, install the necessary dependencies and experiment.

```
git clone git@github.com:switch2osm/switch2osm.git
cd switch2osm
python -m venv venv
source ./venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

Open <http://127.0.0.1:8080/> in your browser.

## Running the Website Locally with Docker

If you prefer to use Docker to run the website locally, follow these steps:

1. Ensure you have Docker installed on your system. If not, you can download it from [Docker's official website](https://www.docker.com/).

2. Navigate to the root directory of the repository in your terminal.

3. Run the following command to build and start the website:

   ```
   docker compose up --build
   ```

4. Open <http://127.0.0.1:8080/> in your browser to view the website.

### Viewing Changes

To view any changes made to the website, you will need to stop the running container and re-run the command above.

## Translation

To add a translation in your language, follow these steps:

1. Begin by editing the `mkdocs.yml` file, which can be found at the root of the repository. To see an example of how to do this, refer to how the Ukrainian translation is added. Once completed, your language will be included in the language switcher, and all menu items and prompts will be displayed in your language.

2. Next, you can start translating the articles' text. Here's how:

   a. Duplicate the `en` folder and replace its name with your language code. Maintain the file names unchanged.

   b. Translate the values of the front matter keys in each Markdown file within your language folder.

   c. In each Markdown file, set the `lang` key in the front matter to match your language code, which should be the same as the name of your language folder.

   d. Preserve the Markdown formatting as is; there's no need to alter it.

3. If you have the `mkdocs serve` script running while making changes, the translated content will be automatically reflected in the displayed content after saving.

By following these steps, you can contribute translations to the project, making it accessible to a broader audience in your language.

## Copyright

© 2013–2025 OpenStreetMap and contributors, [CC BY-SA](http://creativecommons.org/licenses/by-sa/2.0/)
