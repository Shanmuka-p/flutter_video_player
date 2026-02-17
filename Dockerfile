# 1. Use an existing image with the Flutter SDK
FROM cirrusci/flutter:stable

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy project files from your computer to the container
COPY . .

# 4. Install dependencies before building
RUN flutter pub get

# 5. The default command (can be overridden)
CMD ["flutter", "--version"]