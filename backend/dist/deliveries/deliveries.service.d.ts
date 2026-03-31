import { Repository } from 'typeorm';
import { Delivery } from './entities/delivery.entity';
import { DeliveryStatusHistory } from './entities/delivery-status-history.entity';
import { CreateDeliveryDto, UpdateDeliveryDto } from './dto/delivery.dto';
export declare class DeliveriesService {
    private readonly repository;
    private readonly historyRepository;
    constructor(repository: Repository<Delivery>, historyRepository: Repository<DeliveryStatusHistory>);
    create(createDeliveryDto: CreateDeliveryDto): Promise<Delivery>;
    findAll(): Promise<Delivery[]>;
    findOne(id: string): Promise<Delivery>;
    update(id: string, updateDto: UpdateDeliveryDto): Promise<Delivery>;
    findHistory(id: string): Promise<DeliveryStatusHistory[]>;
    remove(id: string): Promise<void>;
}
