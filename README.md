This is a guide to using [Gollum](https://github.com/gollum/gollum) (Git-powered wiki with browser frontend) to run a local wiki with certain requirements:

- Use latest stable version of Gollum (5.3.2 as of this writing)
  - in a container
  - with Podman, not Docker
  - in rootless mode
  - on a SELinux-enabled distro (Fedora 38)
  - via a systemd user service
- Use a [CommonMark](https://commonmark.org/)-compliant parser (`commonmarker` 0.23.9) instead of the default `kramdown`
  - Simple change, see <https://github.com/jn64/gollum/commit/cc8ee236d862ab8bea0e2b53d5a704fdb43b202e>
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
   git add -A
   git commit -m init
   ```

3. Build custom Gollum image that includes commonmarker instead of kramdown:

   ```sh
   podman build -t gollum:v5.3.2-commonmark https://github.com/jn64/gollum.git#v5.3.2-commonmark
   ```

   The resulting image is `localhost/gollum:v5.3.2-commonmark` (check `podman images`).

4. Create a container with this custom image:

   ```sh
   podman run --name gollum -d --rm --security-opt label=disable -v "${HOME}/wiki":/wiki -v "${HOME}/wiki/.gollum":/etc/gollum -p 4567:4567 localhost/gollum:v5.3.2-commonmark --config /etc/gollum/config.rb
   ```

   Test it by opening <http://localhost:4567> in your browser. Make sure it works (edit, create new page, etc).

5. Generate systemd service from the running container's configuration:

   ```sh
   podman generate systemd -n --new gollum | sed -E -e '/^(Wants|After)=network-online.target$/ d' > ~/wiki/.gollum/container-gollum.service
   ```

   (The `sed` removes an unnecessary dependency on `network-online.target`)

6. Stop the container:

   ```sh
   podman container stop gollum
   ```

7. Install and enable the user service:

   ```sh
   systemctl --user enable --now ~/wiki/.gollum/container-gollum.service
   ```

Done. Now the Gollum container will run automatically on your user login.

For convenience, pin or bookmark <http://localhost:4567> in your browser.

## Configuration

See [.gollum/config.rb](.gollum/config.rb)

## References

- <https://github.com/gollum/gollum/wiki/Gollum-via-Docker>
- <https://github.com/gollum/gollum#configuration>
- <https://github.com/gjtorikian/commonmarker/blob/42cfc90251353f9fceda91b884d0ded8d3da0bcf/README.md#options>
