from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import uvicorn
from .solver import solve_vrp

app = FastAPI(title="Last Mile Optimizer")

class DeliveryLocation(BaseModel):
    id: str
    lat: float
    lng: float

class OptimizationRequest(BaseModel):
    locations: List[DeliveryLocation]
    num_vehicles: int = 1
    depot_index: int = 0

@app.get("/")
async def root():
    return {"message": "Optimizer Service is running"}

@app.post("/optimize")
async def optimize(request: OptimizationRequest):
    # Convert Pydantic models to simple list of coords for the solver
    coords = [[loc.lat, loc.lng] for loc in request.locations]
    
    # Simple distance matrix (should be replaced by Google/Mapbox API in production)
    # Placeholder for now
    result = solve_vrp(coords, request.num_vehicles, request.depot_index)
    
    return {
        "optimized_sequence": result,
        "status": "success"
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
