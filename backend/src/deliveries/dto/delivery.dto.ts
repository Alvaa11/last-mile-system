import { IsString, IsNotEmpty, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { DeliveryStatus } from '../entities/delivery.entity';

export class CreateDeliveryDto {
  @IsString()
  @IsNotEmpty()
  customerName: string;

  @IsString()
  @IsNotEmpty()
  address: string;

  @IsString()
  @IsOptional()
  location?: string; // Format: "POINT(lng lat)"

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

  @IsString()
  @IsOptional()
  currentCoords?: string; // For status update auditing
}
