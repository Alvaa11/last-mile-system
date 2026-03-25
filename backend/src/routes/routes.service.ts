import { Injectable } from '@nestjs/common';
import { LocationDto, OptimizeRouteDto } from './dto/optimize-route.dto';
import { DistanceCalculator } from './utils/distance-calculator';

@Injectable()
export class RoutesService {
  optimizeRoute(dto: OptimizeRouteDto): LocationDto[] {
    const { depot, deliveries } = dto;
    const optimizedSequence: LocationDto[] = [depot];
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

  private findNearestLocation(
    origin: LocationDto,
    candidates: LocationDto[],
  ): { location: LocationDto; index: number } {
    let minDistance = Infinity;
    let nearestIndex = -1;

    candidates.forEach((candidate, index) => {
      const distance = DistanceCalculator.calculateHaversineDistance(
        origin.latitude,
        origin.longitude,
        candidate.latitude,
        candidate.longitude,
      );

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
}
