# claude-cloud-env

A tiny demo of **Claude Code cloud environments**.

Every cloud session runs in a fresh, isolated container built from an
*environment*: a saved setup with a network policy, environment variables and
an optional setup script. The repository is cloned in when the container
starts, and the container is thrown away later, so work only survives if it's
committed and pushed.

## Try it

```bash
./whereami.sh
```

It prints:

| Section | What it shows |
| --- | --- |
| Machine | Hostname, OS, CPUs, memory, and whether this is a cloud container |
| Pre-installed tools | Which language runtimes and CLIs are available |
| Network policy | Which sample hosts the environment lets you reach |
| Repository | The repo, branch and commit the session started on |
| Disk | How much of the per-session disk allowance is used |

## Experiment

1. Run `./whereami.sh` in a cloud session and note the output.
2. Edit the environment in Claude Code settings: allow or block a host,
   add an environment variable, or add a setup script
   (e.g. `apt-get install -y cowsay`).
3. Start a new session and run it again. The differences come from the
   environment, not the repo.

Docs: https://code.claude.com/docs/en/claude-code-on-the-web

## Live page (GitHub Pages)

`docs/index.html` is a snapshot of `whereami.sh` output from one cloud
session, laid out as a web page. To publish it, open **Settings → Pages**,
choose **Deploy from a branch**, then pick the branch and the `/docs` folder.
It will appear at `https://<owner>.github.io/claude-cloud-env/`.
