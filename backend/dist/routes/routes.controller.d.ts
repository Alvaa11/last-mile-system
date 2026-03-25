import { RoutesService } from './routes.service';
import { OptimizeRouteDto, LocationDto } from './dto/optimize-route.dto';
export declare class RoutesController {
    private readonly routesService;
    constructor(routesService: RoutesService);
    optimize(dto: OptimizeRouteDto): LocationDto[];
    check(): {
        status: string;
        message: string;
    };
}
