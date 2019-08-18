"use strict";


function handleError(error) {
  if (error.name === 'ConstraintNotSatisfiedError') {
    let v = constraints.video;
    errorMsg(`The resolution ${v.width.exact}x${v.height.exact} px is not supported by your device.`);
  } else if (error.name === 'PermissionDeniedError') {
    errorMsg('Permissions have not been granted to use your camera and ' +
      'microphone, you need to allow the page access to your devices in ' +
      'order for the demo to work.');
  }
  errorMsg(`getUserMedia error: ${error.name}`, error);
}

function errorMsg(msg, error) {
  const errorElement = document.getElementById('main');
  errorElement.innerHTML += `<div class="flash flash-error">${msg}</div>`;
  if (typeof error !== 'undefined') {
    console.error(error);
  }
}

async function initCamera(videoId) {
  try {
    const stream = await navigator.mediaDevices.getUserMedia(constraints);
    document.getElementById(videoId).srcObject = stream;
  } catch (e) {
    handleError(e);
  }
}

const flags = { ids: { video: 'video_area' }, size: { width: 300, height: 300 } };

const constraints = { audio: false, video: {...flags.size, facingMode: "environment" } };

const app = Elm.Main.init( { node: document.getElementById('main'), flags: flags });
app.ports.startCamera.subscribe(function() { initCamera(flags.ids.video) });
