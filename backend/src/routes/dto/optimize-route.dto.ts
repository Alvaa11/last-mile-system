import { IsString, IsNumber, IsOptional, ValidateNested, IsArray } from 'class-validator';
import { Type } from 'class-transformer';

export class LocationDto {
  @IsString()
  id: string;

  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;
}

export class OptimizeRouteDto {
  @ValidateNested()
  @Type(() => LocationDto)
  depot: LocationDto;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LocationDto)
  deliveries: LocationDto[];
}

