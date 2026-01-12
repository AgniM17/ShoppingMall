# Base runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy solution and project files for better caching
COPY Shopping.sln .
COPY ShoppingDemo/ShoppingDemo.csproj ShoppingDemo/

# Restore dependencies
RUN dotnet restore ShoppingDemo/ShoppingDemo.csproj

# Copy everything else
COPY . .

# Publish the app to /app/publish
RUN dotnet publish ShoppingDemo/ShoppingDemo.csproj -c Release -o /app/publish

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ShoppingDemo.dll"]
