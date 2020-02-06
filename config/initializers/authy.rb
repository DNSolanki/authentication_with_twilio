AUTHY = YAML.load_file(Rails.root.join('config/authy.yml'))
Authy.api_key = AUTHY['AUTHY_KEY']
Authy.api_uri = 'https://api.authy.com/'