import { Controller, Post, Body, Get } from '@nestjs/common';
import { RoutesService } from './routes.service';
import { OptimizeRouteDto, LocationDto } from './dto/optimize-route.dto';

@Controller('routes')
export class RoutesController {
  constructor(private readonly routesService: RoutesService) {}

  @Post('optimize')
  optimize(@Body() dto: OptimizeRouteDto): LocationDto[] {
    return this.routesService.optimizeRoute(dto);
  }

  @Get('check')
  check() {
    return { status: 'alive', message: 'RoutesController is working' };
  }
}
