FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates
COPY vise-agent /usr/local/bin/vise-agent
COPY echo_agent_fixture /usr/local/bin/echo_agent_fixture
RUN chmod +x /usr/local/bin/vise-agent /usr/local/bin/echo_agent_fixture
# A real run's cwd for both the ACP session and vise/sandbox/exec
# (crates/vise-session's SANDBOX_WORKSPACE_CWD) -- a real customer image
# would have this populated by whatever checks out the repo; this demo
# fixture does no real git operations, so it never gets created unless
# declared explicitly here.
RUN mkdir -p /workspace
ENV VISE_AGENT_CMD=/usr/local/bin/echo_agent_fixture
# GIT_PUSH_TOKEN is injected at dispatch time (bins/vise-schedulerd), a
# contents:write-only installation token scoped to this one repo -- never
# broad enough to open a PR itself, per this project's security model.
RUN git config --global credential.helper '!f() { echo "username=x-access-token"; echo "password=$GIT_PUSH_TOKEN"; }; f'
EXPOSE 8791
CMD ["/usr/local/bin/vise-agent"]
# rebuild marker: echo_agent_fixture now emits vise/git/pushed after a
# prompt -- content-addressing keys on this file + vise.toml, not the
# rest of the build context, so a binary-only change needs this too
# (VISE-133) or the build silently reuses the stale image.
# rebuild marker: vise-agent now intercepts vise/sandbox/exec and runs it
# directly as a subprocess instead of forwarding to the wrapped agent
# (VISE-137) -- content-addressing keys on this file + vise.toml, not the
# rest of the build context, so a binary-only change needs this too
# (VISE-133) or the build silently reuses the stale image.
# rebuild marker: vise-agent now spawns /bin/sh by absolute path instead
# of relying on PATH resolution (VISE-137) -- binary-only changes need
# this too (VISE-133) or the build silently reuses the stale image.
# rebuild marker: vise-agent now creates its exec cwd if the image didn't
# already (VISE-137) -- binary-only changes need this too (VISE-133) or
# the build silently reuses the stale image.
