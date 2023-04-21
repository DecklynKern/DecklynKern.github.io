var adapter;
var device;

async function main() {

    var adapter = await navigator.gpu.requestAdapter({});
    var device = await adapter.requestDevice();

}