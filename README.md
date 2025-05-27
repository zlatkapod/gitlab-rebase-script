# GitLab MR Rebase Tool

A Bash script that automatically rebases all open merge requests assigned to a GitLab user. This tool helps keep your merge requests up-to-date with the target branch, reducing merge conflicts and streamlining the code review process.

## Features

- 🔄 Automatically rebases all your open merge requests
- 🔍 Works with any GitLab instance (self-hosted or GitLab.com)
- 🛠️ Configurable via command-line arguments or environment variables
- 📊 Provides status updates for each merge request

## Requirements

- Bash shell
- `curl` command
- GitLab personal access token with `api` scope

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/gitlab-mr-rebase-tool.git
   ```

2. Make the script executable:
   ```
   chmod +x rebase-mrs.sh
   ```

## Usage

### Basic Usage

```bash
./rebase-mrs.sh --token YOUR_ACCESS_TOKEN --username YOUR_GITLAB_USERNAME
```

### Command Line Options

```
Usage: ./rebase-mrs.sh [options]
Options:
  -t, --token TOKEN     GitLab Personal Access Token (required)
  -u, --username USER   GitLab username (required)
  -g, --gitlab URL      GitLab API URL (default: https://gitlab.com/api/v4)
  -h, --help            Display this help message and exit
```

### Using Environment Variables

You can also use environment variables instead of command-line arguments:

```bash
export GITLAB_TOKEN=your_access_token
export GITLAB_USERNAME=your_username
export GITLAB_API_URL=https://gitlab.example.com/api/v4  # Optional
./rebase-mrs.sh
```

## Getting a GitLab Personal Access Token

1. Log in to your GitLab instance
2. Go to User Settings > Access Tokens
3. Create a new personal access token with the `api` scope
4. Copy the token and use it with this script

## Security Considerations

- Never commit your GitLab token to version control
- Consider using environment variables or a password manager to store your token

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 
