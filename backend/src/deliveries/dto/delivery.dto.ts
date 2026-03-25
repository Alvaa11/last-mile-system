import { IsString, IsNotEmpty, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { DeliveryStatus } from '../entities/delivery.entity';

export class CreateDeliveryDto {
  @IsString()
  @IsNotEmpty()
  customerName: string;

  @IsString()
  @IsNotEmpty()
  address: string;

  @IsOptional()
  location?: any; // Accept GeoJSON object or string

  @IsNumber()
  @IsOptional()
  priority?: number;

  @IsString()
  @IsOptional()
  qrCodeId?: string;
}

export class UpdateDeliveryDto {
  @IsEnum(DeliveryStatus)
  @IsOptional()
  status?: DeliveryStatus;

  @IsOptional()
  currentCoords?: any; // For status update auditing
}
