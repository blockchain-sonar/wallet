const dataSetMap = new Map();

self.addEventListener('message', event => {
	try {
		checkMessage(event.data);
		const { method, params, id } = event.data;
		console.log(event.data);
	
		switch (method) {
			case "set":
				dataSetMap.set(params.key, params.value);
				event.source.postMessage({
					id: id,
					method: "set",
					result: {
						key: params.key,
						value: true
					}
				});
				break;
			case "get":
				event.source.postMessage({
					id: id,
					method: "get",
					result: {
						key: params.key,
						value: dataSetMap.get(params.key)
					}
				});
				break;
			case "has":
				event.source.postMessage({
					id: id,
					method: "has",
					result: {
						key: params.key,
						value: dataSetMap.has(params.key)
					}
				});
				break;
			case "delete":
				dataSetMap.delete(params.key);
				event.source.postMessage({
					id: id,
					method: "delete",
					result: {
						key: params.key,
						value: true
					}
				});
				break;
			default:
				console.log("Wrong action");
				break;
		}
	} catch (e) {
		console.error(e);
	}
});

const checkMessage = (msg) => {
	if (typeof msg !== "object" || msg === null) {
		throw TypeError("Message must be an object");
	}
	if (msg.method === null) {
		throw TypeError("Message must have 'method'");
	}
	if (msg.id === null) {
		throw TypeError("Message must have 'id'");
	}
	if (msg.params === null) {
		throw TypeError("Message must have 'params'");
	}
}