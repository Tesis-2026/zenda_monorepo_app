# Do's and Don'ts — DDD & Clean Architecture in NestJS

## THE DON'TS (Anti-Patterns to Avoid)

### 1. Anemic Domain Model
**DON'T** put business logic in services while keeping aggregates as dumb data holders.

```typescript
// BAD — logic in service, aggregate is just a data bag
@Injectable()
export class CartCommandServiceImpl {
  async handle(command: CheckoutCartCommand): Promise<Cart> {
    const cart = await this.cartRepository.findById(command.cartId);
    if (cart.items.length === 0) {
      throw new InvalidCartOperationException('Cannot checkout empty cart');
    }
    cart.status = CartStatus.CHECKED_OUT; // Direct mutation! No encapsulation!
    return this.cartRepository.save(cart);
  }
}
```

```typescript
// GOOD — logic in the aggregate
export class Cart extends AuditableAggregateRoot {
  private _status: CartStatus;
  private _items: CartItem[];

  checkout(): void {
    if (this._items.length === 0) {
      throw new InvalidCartOperationException('Cannot checkout empty cart');
    }
    this._status = CartStatus.CHECKED_OUT; // Private field, controlled transition
  }
}

// Service just orchestrates
@Injectable()
export class CartCommandServiceImpl {
  async handle(command: CheckoutCartCommand): Promise<Cart> {
    const cart = await this.cartRepository.findByUserIdAndStatus(command.userId, CartStatus.ACTIVE);
    if (!cart) throw new CartNotFoundException(command.userId);
    cart.checkout(); // Delegate to domain
    return this.cartRepository.save(cart);
  }
}
```

---

### 2. Cross-Context Direct Imports
**DON'T** import a repository, service, or entity from another bounded context's internal files.

```typescript
// BAD — Orders module directly uses Cart's repository
import { CartRepository } from '../../carts/domain/ports/cart.repository'; // VIOLATION

@Injectable()
export class OrderCommandServiceImpl {
  constructor(private readonly cartRepository: CartRepository) {} // Direct cross-context dep!
}
```

```typescript
// GOOD — Orders module uses Carts ACL facade
import { CartContextFacade } from '../../carts/interfaces/acl/cart-context.facade';

@Injectable()
export class OrderCommandServiceImpl {
  constructor(
    @Inject(CartContextFacade)
    private readonly cartFacade: CartContextFacade, // Clean boundary
  ) {}

  async handle(command: CreateOrderFromCartCommand): Promise<Order> {
    const cartDto = await this.cartFacade.getActiveCartByUserId(command.userId);
    if (!cartDto) throw new InvalidOrderOperationException('No active cart');
    // Work with CartDto, never with Cart aggregate directly
  }
}
```

---

### 3. NestJS Decorators in Domain Layer
**DON'T** use NestJS or TypeORM decorators in domain model classes.

```typescript
// BAD — NestJS/TypeORM decorators polluting domain
import { Injectable } from '@nestjs/common';
import { Entity, Column } from 'typeorm';

@Entity('carts') // NO! Domain aggregate is not an ORM entity
export class Cart {
  @Column() // NO!
  status: string;
}

@Injectable() // NO! Domain port should not have NestJS decorators
export abstract class CartCommandService {}
```

```typescript
// GOOD — domain is pure TypeScript
export class Cart extends AuditableAggregateRoot {
  private _status: CartStatus;
  // Plain TypeScript, no decorators
}

// Domain port — plain abstract class, no decorators
export abstract class CartCommandService {
  abstract handle(command: CheckoutCartCommand): Promise<Cart>;
}
```

**The ORM entity lives separately in infrastructure:**
```typescript
// infrastructure/persistence/entities/cart.orm-entity.ts
@Entity('carts')
export class CartEntity {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() status: string;
}
```

---

### 4. Fat Controllers
**DON'T** put business logic or orchestration in controllers.

```typescript
// BAD — controller doing business work
@Controller('api/v1/carts')
export class CartsController {
  constructor(
    private readonly cartRepo: CartRepository,
    private readonly productRepo: ProductRepository, // Multiple repos in controller!
  ) {}

  @Post(':userId/checkout')
  async checkout(@Param('userId') userId: string) {
    const cart = await this.cartRepo.findByUserId(userId);
    if (cart.items.length === 0) throw new Error('Empty cart');
    cart.status = 'CHECKED_OUT';
    await this.cartRepo.save(cart);
    for (const item of cart.items) {
      await this.productRepo.decreaseStock(item.productId, item.quantity); // Logic in controller!
    }
    return cart;
  }
}
```

```typescript
// GOOD — controller is thin, delegates to service
@Controller('api/v1/carts')
@UseGuards(JwtAuthGuard)
export class CartsController {
  constructor(private readonly cartCommandService: CartCommandService) {}

  @Post('me/checkout')
  async checkout(@CurrentUser('id') userId: string): Promise<CartResponseDto> {
    const cart = await this.cartCommandService.handle(new CheckoutCartCommand({ userId }));
    return CartRestMapper.toResponse(cart);
  }
}
```

---

### 5. Leaking Domain Types to API
**DON'T** return domain aggregates directly from controllers. Always map to response DTOs.

```typescript
// BAD — exposing domain aggregate
@Get(':id')
async getProduct(@Param('id') id: string): Promise<Product> {
  return this.productQueryService.handle(new GetProductByIdQuery({ productId: id }));
}
```

```typescript
// GOOD — map to response DTO
@Get(':id')
async getProduct(@Param('id') id: string): Promise<ProductResponseDto> {
  const product = await this.productQueryService.handle(new GetProductByIdQuery({ productId: id }));
  if (!product) throw new ProductNotFoundException(id);
  return ProductRestMapper.toResponse(product);
}
```

---

### 6. God Aggregates
**DON'T** make one aggregate responsible for too many things. If your aggregate has 15+ fields or 20+ methods, it probably needs to be split into separate bounded contexts.

---

### 7. Mutable Commands/Queries
**DON'T** use plain objects or mutable classes for commands and queries.

```typescript
// BAD — mutable, no validation
const command = {
  userId: '123',
  productId: '456',
  quantity: -1, // Invalid but no one checks!
};
```

```typescript
// GOOD — immutable class with constructor validation
export class AddProductToCartCommand {
  readonly userId: string;
  readonly productId: string;
  readonly quantity: number;

  constructor(props: { userId: string; productId: string; quantity: number }) {
    if (props.quantity <= 0) throw new Error('Quantity must be positive');
    this.userId = props.userId;
    this.productId = props.productId;
    this.quantity = props.quantity;
  }
}
```

---

### 8. Using TypeORM Entities as Domain Models
**DON'T** use the same class for ORM mapping and domain logic. This is the #1 mistake in NestJS DDD projects.

```typescript
// BAD — single class trying to be both ORM entity AND domain model
@Entity('carts')
export class Cart {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() status: string;
  @OneToMany(() => CartItem, (item) => item.cart) items: CartItem[];

  // Domain logic mixed with ORM decorators
  checkout() {
    if (this.items.length === 0) throw new Error('Empty');
    this.status = 'CHECKED_OUT';
  }
}
```

```typescript
// GOOD — separate concerns

// Domain (pure TypeScript class with logic)
export class Cart extends AuditableAggregateRoot {
  private _status: CartStatus;
  private _items: CartItem[];
  checkout(): void { /* business logic */ }
}

// Infrastructure (ORM mapping only, no logic)
@Entity('carts')
export class CartEntity {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() status: string;
  @OneToMany(() => CartItemEntity, (item) => item.cart) items: CartItemEntity[];
}

// Mapper bridges the two
export class CartPersistenceMapper {
  static toDomain(entity: CartEntity): Cart { /* ... */ }
  static toOrmEntity(aggregate: Cart): CartEntity { /* ... */ }
}
```

---

### 9. Barrel File Imports Across Layers
**DON'T** create `index.ts` barrel files that re-export across architectural layers. They create hidden coupling.

```typescript
// BAD — barrel file in carts/ root
// src/carts/index.ts
export * from './domain/model/aggregates/cart.aggregate';
export * from './infrastructure/persistence/entities/cart.orm-entity';
export * from './application/command-services/cart-command.service-impl';

// Now anyone can import internal types:
import { CartCommandServiceImpl } from '../carts'; // Breaks encapsulation!
```

```typescript
// GOOD — import exactly what you need from the exact file
import { CartContextFacade } from '../carts/interfaces/acl/cart-context.facade';
// Only the ACL facade should be importable from outside the context
```

---

### 10. Shared Database Tables Between Contexts
**DON'T** have two bounded contexts write to the same table. Each context owns its data. If context B needs data from context A, it goes through the ACL facade.

---

### 11. Skipping Guards on Endpoints
**DON'T** create controller endpoints without guards. Every endpoint MUST have explicit authorization.

```typescript
// BAD — no guard
@Get('users')
async getUsers() { }

// GOOD — explicit guard
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@Get('users')
async getUsers() { }
```

At minimum, apply `@UseGuards(JwtAuthGuard)` at the class level for all authenticated endpoints.

---

### 12. Putting Validation Only in DTOs
**DON'T** rely solely on `class-validator` in DTOs. Domain invariants belong in the aggregate or command constructor.

```typescript
// DTO validates shape (good, but not sufficient)
export class CreateCartItemDto {
  @IsString() @IsNotEmpty() productId: string;
  @IsInt() @Min(1) quantity: number;
}

// Command validates business preconditions
export class AddProductToCartCommand {
  constructor(props: { userId: string; productId: string; quantity: number }) {
    if (props.quantity <= 0) throw new Error('Quantity must be positive');
    // ...
  }
}

// Aggregate validates business RULES
export class Cart {
  addItem(productId: string, quantity: number, availableStock: number): void {
    if (quantity > availableStock) {
      throw new InvalidCartOperationException('Insufficient stock');
    }
  }
}

// All three layers of validation work together
```

---

### 13. Injecting Concrete Classes Instead of Ports
**DON'T** inject concrete implementations directly. Always inject via the abstract port or token.

```typescript
// BAD — coupled to implementation
@Injectable()
export class CartCommandServiceImpl {
  constructor(private readonly repo: TypeOrmCartRepository) {} // Concrete class!
}
```

```typescript
// GOOD — depends on abstraction
@Injectable()
export class CartCommandServiceImpl {
  constructor(private readonly cartRepository: CartRepository) {} // Abstract port!
}
// Wired in module: { provide: CartRepository, useClass: TypeOrmCartRepository }
```

---

## THE DO's (Best Practices)

### 1. DO Use the Shared Base Classes
All aggregates extend `AuditableAggregateRoot`. All child entities extend `AuditableEntity`. This gives you `id`, `createdAt`, `updatedAt` for free.

### 2. DO Keep Services as Orchestrators
Services fetch aggregates (via repository port), call domain methods, persist results, and coordinate cross-context calls via ACL. That's it — no business logic.

### 3. DO Return `null` for Query Misses
Query services return `Promise<Entity | null>`. Let the caller (controller/resolver) decide how to handle absence (throw 404, return null for GraphQL, etc.).

### 4. DO Use `OnApplicationBootstrap` for Seeding
Lookup data (statuses, roles) is populated via `Seed...Command` triggered by implementing the `OnApplicationBootstrap` lifecycle hook.

```typescript
@Injectable()
export class CartSeederHandler implements OnApplicationBootstrap {
  async onApplicationBootstrap(): Promise<void> {
    await this.cartCommandService.handle(new SeedCartStatusesCommand());
  }
}
```

### 5. DO Use TypeORM QueryRunner for Transactions
Wrap complex multi-step writes in an explicit transaction at the command service level.

```typescript
@Injectable()
export class OrderCommandServiceImpl {
  constructor(private readonly dataSource: DataSource) {}

  async handle(command: CreateOrderFromCartCommand): Promise<Order> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();
    try {
      // ... multiple writes
      await queryRunner.commitTransaction();
    } catch (err) {
      await queryRunner.rollbackTransaction();
      throw err;
    } finally {
      await queryRunner.release();
    }
  }
}
```

### 6. DO Make ACL DTOs Minimal
ACL DTOs should contain only what the consuming context needs. Don't expose the entire aggregate structure. Use plain interfaces, not classes.

### 7. DO Separate ORM Entities from Domain Aggregates
This is the most important NestJS-specific rule. Your `@Entity()` decorated class in infrastructure is NOT your domain model. Use a persistence mapper to bridge them.

### 8. DO Use Global Exception Filters
The shared `AllExceptionsFilter` maps domain exceptions to standardized HTTP error responses. All new exceptions should extend the shared base hierarchy.

```typescript
// shared/infrastructure/filters/all-exceptions.filter.ts

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();

    if (exception instanceof ResourceNotFoundException) {
      response.status(404).json({ statusCode: 404, message: exception.message });
    } else if (exception instanceof InvalidOperationException) {
      response.status(400).json({ statusCode: 400, message: exception.message });
    } else if (exception instanceof BusinessRuleException) {
      response.status(409).json({ statusCode: 409, message: exception.message });
    } else {
      response.status(500).json({ statusCode: 500, message: 'Internal server error' });
    }
  }
}
```

### 9. DO Separate REST and GraphQL DTOs
Even if they look similar, keep separate DTO classes for REST and GraphQL. REST uses `class-validator`, GraphQL uses `@ObjectType()/@InputType()`. They evolve independently.

### 10. DO Cache at the Application Layer
Use NestJS `CacheInterceptor` or `@nestjs/cache-manager` at the application service level. Never cache at the repository or controller level.

```typescript
@Injectable()
export class ProductQueryServiceImpl extends ProductQueryService {
  constructor(
    private readonly productRepository: ProductRepository,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
  ) { super(); }

  async handle(query: GetProductByIdQuery): Promise<Product | null> {
    const cacheKey = `product:${query.productId}`;
    const cached = await this.cacheManager.get<Product>(cacheKey);
    if (cached) return cached;

    const product = await this.productRepository.findById(query.productId);
    if (product) await this.cacheManager.set(cacheKey, product, 300_000);
    return product;
  }
}
```

### 11. DO Design State Machines Explicitly
For entities with lifecycle states, define valid transitions in the domain and reject invalid ones.

```typescript
// domain/model/value-objects/delivery-status.enum.ts

export enum DeliveryStatus {
  PACKED = 'PACKED',
  SHIPPED = 'SHIPPED',
  IN_TRANSIT = 'IN_TRANSIT',
  DELIVERED = 'DELIVERED',
}

const VALID_TRANSITIONS: Record<DeliveryStatus, DeliveryStatus[]> = {
  [DeliveryStatus.PACKED]: [DeliveryStatus.SHIPPED],
  [DeliveryStatus.SHIPPED]: [DeliveryStatus.IN_TRANSIT],
  [DeliveryStatus.IN_TRANSIT]: [DeliveryStatus.DELIVERED],
  [DeliveryStatus.DELIVERED]: [],
};

export function canTransition(from: DeliveryStatus, to: DeliveryStatus): boolean {
  return VALID_TRANSITIONS[from].includes(to);
}
```

### 12. DO Use `@Global()` Only for the Shared Module
Only the `SharedModule` should be `@Global()`. Context modules should explicitly import other context modules when they need their ACL facades.

---

## Checklist Before Committing Code

- [ ] Business logic is in the aggregate, not the service
- [ ] No cross-context direct imports (using ACL facades via DI tokens)
- [ ] Commands and queries are readonly classes with constructor validation
- [ ] Constructor injection everywhere (no property injection)
- [ ] Every endpoint has a guard (`@UseGuards`)
- [ ] Domain aggregates are never returned from controllers (use mappers)
- [ ] ORM entities are separate from domain aggregates (with persistence mapper)
- [ ] Transactions are managed at the command service level, not repo/controller
- [ ] New exceptions extend the shared base hierarchy
- [ ] The module only exports the ACL facade token
- [ ] No NestJS/TypeORM decorators in the domain layer
- [ ] Tests exist for aggregate business logic (pure unit tests, no mocks)
- [ ] `tokens.ts` (or abstract class tokens) defined for all injectable ports
