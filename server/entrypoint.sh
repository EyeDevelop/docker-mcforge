#!/bin/bash

if [[ -z "$(id mcuser 2>/dev/null)" ]]; then
    addgroup -g "${PGID}" mcuser
    adduser -H -D -G mcuser -u "${PUID}" mcuser
fi

if [[ ! -d "/server" ]]; then
    mkdir -p /server
    chown -R mcuser:mcuser /server
fi

if [[ ! -f "/server/forge.jar" ]]; then
    echo "Downloading and installing Minecraft Forge..."

    curl -o /server/forge-installer.jar -L "https://files.minecraftforge.net/maven/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar"
    java -jar /server/forge-installer.jar --installServer /server
    rm -f /server/forge-installer.jar
    mv /server/forge*.jar /server/forge.jar
fi

if [[ ! -f "/server/eula.txt" ]]; then
    echo "IF YOU DO NOT AGREE WITH THE MINECRAFT SERVER EULA, STOP HERE."
    echo "Auto-accepting the EULA..."
    echo "eula=true" > /server/eula.txt
fi

if [[ ! -f "/run.sh" ]]; then
    cat << EOF > "/run.sh"
#!/bin/bash
cd /server
java -Xmx\${MEMORY_USAGE} -Xms\${MEMORY_USAGE} -jar forge.jar nogui
EOF

    chmod +x /run.sh
fi

su-exec mcuser:mcuser /run.sh
