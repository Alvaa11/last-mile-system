import { Delivery, DeliveryStatus } from './delivery.entity';
export declare class DeliveryStatusHistory {
    id: string;
    delivery: Delivery;
    status: DeliveryStatus;
    coords: string;
    notes: string;
    timestamp: Date;
}
