const dataSetMap = new Map();

self.addEventListener('message', event => {
	try {
		checkMessage(event.data);
		const { method, params, id } = event.data;

		switch (method) {
			case "set":
				dataSetMap.set(params.name, params.value);
				break;
			case "get":
				event.source.postMessage({
					id: id,
					result: {
						name: params.name,
						value: dataSetMap.get(params.name)
					}
				});
				break;
			case "has":
				event.source.postMessage({
					id: id,
					result: {
						name: params.name,
						value: dataSetMap.has(params.name)
					}
				});
				break;
			case "delete":
				dataSetMap.delete(params.name);
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