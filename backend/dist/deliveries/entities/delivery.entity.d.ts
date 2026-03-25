export declare enum DeliveryStatus {
    PENDING = "PENDING",
    IN_TRANSIT = "IN_TRANSIT",
    DELIVERED = "DELIVERED",
    FAILED = "FAILED"
}
export declare class Delivery {
    id: string;
    customerName: string;
    address: string;
    location: any;
    status: DeliveryStatus;
    priority: number;
    qrCodeId: string;
    createdAt: Date;
    updatedAt: Date;
}
