This is a guide to using [Gollum](https://github.com/gollum/gollum) (Git-powered wiki with browser frontend) to run a local wiki with certain requirements:

- Use latest stable version of Gollum (6.1.0 as of this writing)
  - in a container
  - with rootless Podman
  - on a SELinux-enabled distro (Fedora 41)
  - via a systemd user service
- Use a [CommonMark](https://commonmark.org/)-compliant parser (`commonmarker` 0.23.11) instead of the default `kramdown`
  - We're stuck with commonmarker <1.0 due to [breaking changes](https://github.com/github/markup/issues/1758).
- Store Gollum config in the same place as wiki contents

## Instructions

We will use this branch as the basis of a new wiki, with some example config included.

1. Clone this branch to `~/wiki`. This will be your wiki.

   ```sh
   git clone -b example --depth 1 https://github.com/jn64/gollum.git ~/wiki
   ```

2. Reset the git history (you don't need your wiki to be linked to this repo):

   ```sh
   cd ~/wiki
   rm -rf ~/wiki/.git
   git init -b main
   git add .
   git commit -m init
   ```

3. Build custom Gollum image that includes commonmarker instead of kramdown:

   ```sh
   podman build -t gollum:v6.1.0-commonmark https://github.com/jn64/gollum.git#v6.1.0-commonmark
   ```

   The resulting image is `localhost/gollum:v6.1.0-commonmark` (see `podman image list`).

4. Create a temporary container with this custom image:

   ```sh
   podman run --name gollum --rm --init -v ~/wiki:/wiki:z -v ~/wiki/.gollum:/etc/gollum:z -p 4567:4567 --userns=keep-id:uid=1000,gid=1000 gollum:v6.1.0-commonmark -- --config /etc/gollum/config.rb
   ```

   Test it by visiting <http://localhost:4567> in your browser. Make sure it works (edit, create new page, etc).

5. Stop the container with Ctrl-C, or in another terminal:

   ```sh
   podman container stop gollum
   ```

6. Generate quadlet from previous podman-run command:

   ```sh
   mkdir -p ~/.config/containers/systemd
   podlet -i podman run --name gollum --rm --init -v ~/wiki:/wiki:z -v ~/wiki/.gollum:/etc/gollum:z -p 4567:4567 --userns=keep-id:uid=1000,gid=1000 gollum:v6.1.0-commonmark -- --config /etc/gollum/config.rb > ~/.config/containers/systemd/gollum.container
   ```

7. Start the service:

   ```sh
   systemctl --user daemon-reload
   systemctl --user start gollum
   ```

Done! The service will start automatically at your user login.

For convenience, pin or bookmark <http://localhost:4567> in your browser.

## Configuration

See [.gollum/config.rb](.gollum/config.rb)

## References

- <https://github.com/gollum/gollum/wiki/Gollum-via-Docker>
- <https://github.com/gollum/gollum#configuration>
- <https://github.com/gjtorikian/commonmarker/blob/v0.23.11/README.md#options>
- [Auto-generating a systemd unit file using Quadlets](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/building_running_and_managing_containers/index#auto-generating-a-systemd-unit-file-using-quadlets_assembly_porting-containers-to-systemd-using-podman)
- [containers/podlet: Generate Podman Quadlet files from a Podman command, compose file, or existing object](https://github.com/containers/podlet)
