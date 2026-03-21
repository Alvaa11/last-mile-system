import { DeliveriesService } from './deliveries.service';
import { CreateDeliveryDto, UpdateDeliveryDto } from './dto/delivery.dto';
export declare class DeliveriesController {
    private readonly deliveriesService;
    constructor(deliveriesService: DeliveriesService);
    create(createDeliveryDto: CreateDeliveryDto): Promise<import("./entities/delivery.entity").Delivery>;
    findAll(): Promise<import("./entities/delivery.entity").Delivery[]>;
    findOne(id: string): Promise<import("./entities/delivery.entity").Delivery>;
    update(id: string, updateDeliveryDto: UpdateDeliveryDto): Promise<import("./entities/delivery.entity").Delivery>;
    remove(id: string): Promise<void>;
}
