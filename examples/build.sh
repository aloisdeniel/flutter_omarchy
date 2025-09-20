
dart pub global activate mason_cli

rm -rf ./app
mason make omarchy_app -o ./app --project_name app --executable_name app --description "A simple Omarchy application." --author "Your Name" --config_path="\$HOME/.config/\$PROJECT_NAME/config.yaml"
