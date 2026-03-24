import requests
url = "http://localhost:8000/optimize"
payload = {
    "locations": [
        {"id": "depot", "lat": -23.5505, "lng": -46.6333},
        {"id": "entrega_1", "lat": -23.5595, "lng": -46.6388},
        {"id": "entrega_2", "lat": -23.5650, "lng": -46.6520}
    ],
    "num_vehicles": 1,
    "depot_index": 0
}
response = requests.post(url, json=payload)
print(response.json())