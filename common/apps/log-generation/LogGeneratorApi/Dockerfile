FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /source

# Copy everything
COPY . ./
# Restore as distinct layers
RUN dotnet restore
# Build and publish a release
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy-chiseled-amd64
ENV ASPNETCORE_HTTP_PORTS=80
WORKDIR /App
COPY --from=build-env /source/out .
ENTRYPOINT ["dotnet", "LogGeneratorApi.dll"]