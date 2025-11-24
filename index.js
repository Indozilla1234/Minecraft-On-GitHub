const { Client, Authenticator } = require('minecraft-launcher-core');
const launcher = new Client();
const version = "1.21.10" // change this to your desired version (also update java version)

let opts = {
    authorization: Authenticator.getAuth("TestPlayer"),
    root: "./minecraft",
    version: {
        number: version,
        type: "release"
    },
    memory: {
        max: "6G",
        min: "4G"
    },
    javaPath: "java",
    overrides: {
        detached: false
    },
    customArgs: [
        "-Dorg.lwjgl.opengl.Display.allowSoftwareOpenGL=true",
        "-Dorg.lwjgl.system.allocator=system"
    ]
}

launcher.launch(opts);

launcher.on('debug', (e) => console.log(e));
launcher.on('data', (e) => console.log(e));