import { DeliveryStatus } from '../entities/delivery.entity';
export declare class CreateDeliveryDto {
    customerName: string;
    address: string;
    location?: any;
    priority?: number;
    qrCodeId?: string;
}
export declare class UpdateDeliveryDto {
    status?: DeliveryStatus;
    currentCoords?: any;
}
