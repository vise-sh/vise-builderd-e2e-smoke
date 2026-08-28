FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates
COPY vise-agent /usr/local/bin/vise-agent
COPY echo_agent_fixture /usr/local/bin/echo_agent_fixture
RUN chmod +x /usr/local/bin/vise-agent /usr/local/bin/echo_agent_fixture
ENV VISE_AGENT_CMD=/usr/local/bin/echo_agent_fixture
# GIT_PUSH_TOKEN is injected at dispatch time (bins/vise-schedulerd), a
# contents:write-only installation token scoped to this one repo -- never
# broad enough to open a PR itself, per this project's security model.
RUN git config --global credential.helper '!f() { echo "username=x-access-token"; echo "password=$GIT_PUSH_TOKEN"; }; f'
EXPOSE 8791
CMD ["/usr/local/bin/vise-agent"]
