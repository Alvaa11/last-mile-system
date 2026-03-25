"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RoutesService = void 0;
const common_1 = require("@nestjs/common");
const distance_calculator_1 = require("./utils/distance-calculator");
let RoutesService = class RoutesService {
    optimizeRoute(dto) {
        const { depot, deliveries } = dto;
        const optimizedSequence = [depot];
        const unvisited = [...deliveries];
        let currentPosition = depot;
        while (unvisited.length > 0) {
            const nearest = this.findNearestLocation(currentPosition, unvisited);
            optimizedSequence.push(nearest.location);
            unvisited.splice(nearest.index, 1);
            currentPosition = nearest.location;
        }
        return optimizedSequence;
    }
    findNearestLocation(origin, candidates) {
        let minDistance = Infinity;
        let nearestIndex = -1;
        candidates.forEach((candidate, index) => {
            const distance = distance_calculator_1.DistanceCalculator.calculateHaversineDistance(origin.latitude, origin.longitude, candidate.latitude, candidate.longitude);
            if (distance < minDistance) {
                minDistance = distance;
                nearestIndex = index;
            }
        });
        return {
            location: candidates[nearestIndex],
            index: nearestIndex,
        };
    }
};
exports.RoutesService = RoutesService;
exports.RoutesService = RoutesService = __decorate([
    (0, common_1.Injectable)()
], RoutesService);
//# sourceMappingURL=routes.service.js.map