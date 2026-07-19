# Linux System Administration Fundamentals

An interactive, hands-on Educates workshop that teaches Linux system
administration on Ubuntu Server 24.04 LTS.

---

## About this Workshop

| Field       | Value                                       |
|-------------|---------------------------------------------|
| Platform    | Ubuntu Server 24.04 LTS                     |
| Duration    | 4 Hours                                     |
| Audience    | Beginners with basic IT knowledge           |
| Environment | Dedicated Ubuntu container per student      |
| Renderer    | Educates Hugo renderer                      |

---

## Modules

| # | Module                              | Topics                                       |
|---|-------------------------------------|----------------------------------------------|
| 1 | Linux and Ubuntu Fundamentals       | Architecture, kernel, FHS, sudo, hostname    |
| 2 | Command Line Administration         | Navigation, pipes, redirection, grep, find   |
| 3 | Filesystem and Storage              | Links, mounts, disk usage, inodes, df/du     |
| 4 | Users, Groups and Permissions       | useradd, groupadd, chmod, chown, sudo, ACL   |
| 5 | Package Management                  | APT, DPKG, repositories, install/remove      |
| 6 | Processes, Services and Logs        | systemctl, journalctl, kill, top, htop       |
| 7 | Networking                          | ip, ss, ping, SSH, SCP, curl, DNS            |

---

## Repository Structure

```
workshop/
├── workshop.yaml          # Educates Workshop CRD definition
├── config.yaml            # Hugo renderer pathway/module config
├── hugo.toml              # Hugo configuration (contentDir = "instructions")
├── README.md
│
├── instructions/          # Workshop markdown content pages (Hugo content dir)
│   ├── 01-linux-fundamentals.md
│   ├── 02-command-line.md
│   ├── 03-filesystem.md
│   ├── 04-users.md
│   ├── 05-packages.md
│   ├── 06-processes.md
│   └── 07-networking.md
│
├── examiner/
│   └── tests/             # Automated verification scripts (bash, exit 0 = pass)
│       ├── check-nginx-installed
│       ├── check-nginx-running
│       ├── check-user-exists
│       ├── check-group-exists
│       ├── check-sudo-config
│       ├── check-htop-installed
│       ├── check-permissions
│       └── check-ssh-running
│
├── scripts/
│   ├── setup.sh           # Initial environment provisioning
│   ├── reset.sh           # Resets lab state between runs
│   └── check.sh           # Manual environment health check
│
├── resources/
│   └── workshop-environment.yaml  # Kubernetes WorkshopEnvironment resource
│
└── assets/
    └── images/            # Diagrams and screenshots
```

> **Educates content path note:** This workshop uses the Hugo renderer with
> `contentDir = "instructions"` configured in `hugo.toml`. The instruction
> markdown files live in `workshop/instructions/`, matching the logical
> structure shown above. If you need to use the classic renderer, rename
> `instructions/` to `content/` and remove `hugo.toml`.

---

## Quick Start (Local Deployment)

### Prerequisites

- Educates CLI installed: https://docs.educates.dev/getting-started/quick-start-guide
- Docker or a local Kubernetes cluster (kind)

### Deploy

```bash
# Start a local Educates cluster
educates create-cluster

# Deploy this workshop
educates publish-workshop
educates deploy-workshop

# Open the training portal
educates browse-workshops
```

### Cleanup

```bash
educates delete-workshop lab-linux-sysadmin
```

---

## Verification Scripts

Each lab step has an automated verifier in `workshop/examiner/tests/`.
Scripts exit `0` for PASS, non-zero for FAIL.

| Script                  | Checks                                  |
|-------------------------|-----------------------------------------|
| `check-nginx-installed` | nginx package is installed via dpkg     |
| `check-nginx-running`   | nginx service is active/running         |
| `check-user-exists`     | devuser1 account was created            |
| `check-group-exists`    | developers group was created            |
| `check-sudo-config`     | student is in sudo group                |
| `check-htop-installed`  | htop binary exists                      |
| `check-permissions`     | /opt/devshare has correct SGID mode     |
| `check-ssh-running`     | sshd is listening on port 22            |

---

## Contributing

1. Fork the repository
2. Edit files in `workshop/instructions/`
3. Test locally with `educates deploy-workshop --watch`
4. Submit a pull request

---

## License

Apache License 2.0 — see [LICENSE](../LICENSE).
