import { LocationDto, OptimizeRouteDto } from './dto/optimize-route.dto';
export declare class RoutesService {
    optimizeRoute(dto: OptimizeRouteDto): LocationDto[];
    private findNearestLocation;
}
