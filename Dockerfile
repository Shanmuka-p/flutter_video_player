# Use the actively maintained GitHub Container Registry image
FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

COPY . .

# Install dependencies before building
RUN flutter pub get

# The default command
CMD ["flutter", "--version"]