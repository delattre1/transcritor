FROM --platform=linux/amd64 public.ecr.aws/e1h7x4a2/plow-cloud-agents:base-ef0019372ff8bca593611b31ebd2e08f9f1458ff@sha256:a8a2f97ad78b8192d80a984dce81d3bf5a9a883d18cb7b677704913a09b56aee

# Agent Identity and Personality
COPY runtime/SOUL.md /var/lib/hermes/SOUL.md
COPY LICENSE /usr/share/doc/transcritor/

# Shipped at /opt/hermes/skills
COPY skills/ /opt/hermes/skills/

# Normalize permissions preserving executable bits
RUN find /opt/hermes/skills -mindepth 1 -type d -exec chmod 0755 {} + \
 && find /opt/hermes/skills -mindepth 1 -type f ! -perm -u+x -exec chmod 0644 {} + \
 && find /opt/hermes/skills -mindepth 1 -type f -perm -u+x -exec chmod 0755 {} + \
 && chmod 0644 /var/lib/hermes/SOUL.md

# Install python dependencies for transcription tools in the agent venv and create system symlinks
RUN uv pip install --python /opt/hermes/.venv yt-dlp youtube-transcript-api SpeechRecognition pydub requests python-dotenv \
 && ln -sf /opt/hermes/.venv/bin/yt-dlp /usr/local/bin/yt-dlp \
 && ln -sf /opt/hermes/.venv/bin/python3 /usr/local/bin/python \
 && ln -sf /opt/hermes/.venv/bin/python3 /usr/local/bin/python3

# The Agent Index usage reporter (agent-index s6 service + client) is the base image's own.
