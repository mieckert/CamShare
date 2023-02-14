if (!navigator.mediaDevices || !navigator.mediaDevices.enumerateDevices) {
    console.log("enumerateDevices() not supported.");        
}

let camName = "";

function screenshot() {

}

// TODO: add value of main camera (must be sent to server)
function server_command(cmd) {
    return (async () => {
        data = { 
            "cmd": cmd,
            "cam": camLocalizedName
        };
        const response = await fetch('/cmd', {
            method: 'POST',            
            cache: 'no-cache',
            headers: {
                'Content-Type': 'application/json'                
            },
            body: JSON.stringify(data)
        });        

        console.log(await response.json());
    });
}

async function checkCameraPermission() {
    let perm = await navigator.permissions.query({name: "camera"});
    while(perm.state == 'prompt') {
        const mainStream = await navigator.mediaDevices.getUserMedia({ video: { } });        
        perm = await navigator.permissions.query({name: "camera"});
    }
    
    if(perm.state == 'denied') {
        let div = document.getElementById("videoWrapper");
        div.innerHTML = "<div class=\"error\">Permission to access camera denied. Reset your browser's permissions (e.g., by clicking &#9432; in the address bar)</div>"
    }
}

async function checkServerSettings() {
    const response = await fetch('/rest/getSettings', {
        method: 'GET',
        cache: 'no-cache'
    });
    const settings = await response.json();
    
    if( settings.camName != camName ) {
        console.log(`New camName = "${camName}"`)
        camName = settings.camName;
        await setCamera();
    }
    
    document.getElementById("controls").style.visibility = settings.hide ? 'hidden' : 'visible';
    window.setTimeout(checkServerSettings, 1000);
}

function getCamLocalizedName(label) {
    console.log(`getCamLocalizedName( label = "${label}"`);
    const cutOff = label.lastIndexOf("(");
    camLocalizedName = label.substring(0, cutOff).trimEnd();
    console.log("return camLocalizedName = " + camLocalizedName);
    return camLocalizedName;
}

async function setCamera() {
    let devices = await navigator.mediaDevices.enumerateDevices();
    console.log(devices);
    devices.filter( (device) => device.kind == "videoinput" ).forEach( (device) => {
        console.log("Device: "    + device.label);
    });

    const camDevice = devices.find( (device) => device.kind == 'videoinput' && getCamLocalizedName(device.label) == camName );
    if(!camDevice) {
        console.log(`No camera found for "${camName}"`);
    }
    console.log(`Using as main camera: ${camDevice.label}`);

    const mainStream = await navigator.mediaDevices.getUserMedia({
        video: {
            width: 1280, height: 720,
            //width: 1920, height: 1080,
            deviceId: {exact: camDevice.deviceId}
        }
    });
    console.log(mainStream);

    const mainVideoElem = document.getElementById('mainVideo');
    mainVideoElem.srcObject = mainStream;
    mainVideoElem.play();
}

(async () => {
    try {        
        document.getElementById("screenshot").addEventListener('click', screenshot);
        serverCommandElementIds = [
            "focus-freeze", "focus-plus", "focus-minus", "exp-freeze", "exp-plus", "exp-minus"
        ];
        for(let elementId of serverCommandElementIds) {
            document.getElementById(elementId).addEventListener('click', server_command(elementId));
        }

        console.log("checking Camera Permissions");
        await checkCameraPermission();
        console.log("checking Server Settings for first time");
        await checkServerSettings();
    }
    catch(err) {
        console.log(err.name + ": " + err.message);
        console.log(err.stack)
    }
})();
