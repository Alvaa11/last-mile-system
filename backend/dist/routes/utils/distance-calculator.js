"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DistanceCalculator = void 0;
class DistanceCalculator {
    static calculateHaversineDistance(lat1, lon1, lat2, lon2) {
        const dLat = this.toRadians(lat2 - lat1);
        const dLon = this.toRadians(lon2 - lon1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.toRadians(lat1)) *
                Math.cos(this.toRadians(lat2)) *
                Math.sin(dLon / 2) *
                Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return this.EARTH_RADIUS_KM * c;
    }
    static toRadians(degrees) {
        return degrees * (Math.PI / 180);
    }
}
exports.DistanceCalculator = DistanceCalculator;
DistanceCalculator.EARTH_RADIUS_KM = 6371;
//# sourceMappingURL=distance-calculator.js.map