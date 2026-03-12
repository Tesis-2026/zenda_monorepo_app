# Naming Conventions & Code Examples

## Naming Rules (non-negotiable)

### Aggregate Roots
- **Name:** Singular `PascalCase` — `Cart`, `Product`, `Order`, `User`
- **Extends:** `AuditableAggregateRoot`
- **File:** `<name>.aggregate.ts` in `domain/model/aggregates/`
- **Rule:** Plain TypeScript class. NO NestJS decorators. NO TypeORM decorators.

```typescript
// domain/model/aggregates/cart.aggregate.ts

import { AuditableAggregateRoot } from '../../../shared/domain/aggregates/auditable-aggregate-root';
import { CartItem } from '../entities/cart-item.entity';
import { CartStatus } from '../value-objects/cart-status.enum';
import { InvalidCartOperationException } from '../../exceptions/invalid-cart-operation.exception';

export class Cart extends AuditableAggregateRoot {
  private _status: CartStatus;
  private _items: CartItem[];
  private _userId: string;

  constructor(props: { id?: string; userId: string; status: CartStatus; items?: CartItem[] }) {
    super(props.id);
    this._userId = props.userId;
    this._status = props.status;
    this._items = props.items ?? [];
  }

  // Business logic LIVES HERE
  addItem(productId: string, quantity: number, availableStock: number): void {
    if (quantity > availableStock) {
      throw new InvalidCartOperationException('Insufficient stock');
    }

    const existing = this._items.find((i) => i.productId === productId);
    if (existing) {
      existing.increaseQuantity(quantity);
    } else {
      this._items.push(new CartItem({ productId, quantity, cart: this }));
    }
  }

  checkout(): void {
    if (this._items.length === 0) {
      throw new InvalidCartOperationException('Cannot checkout empty cart');
    }
    this._status = CartStatus.CHECKED_OUT;
  }

  // Getters — no setters, state changes go through methods
  get status(): CartStatus { return this._status; }
  get items(): ReadonlyArray<CartItem> { return [...this._items]; }
  get userId(): string { return this._userId; }
}
```

### Shared Base Class

```typescript
// shared/domain/aggregates/auditable-aggregate-root.ts

export abstract class AuditableAggregateRoot {
  readonly id: string;
  readonly createdAt: Date;
  updatedAt: Date;

  protected constructor(id?: string) {
    this.id = id ?? crypto.randomUUID();
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }
}
```

### Child Entities
- **Name:** Singular `PascalCase` — `CartItem`, `OrderItem`, `ProductImage`, `Address`
- **Extends:** `AuditableEntity` (if audit needed) or standalone plain class
- **File:** `<name>.entity.ts` in `domain/model/entities/`

```typescript
// domain/model/entities/cart-item.entity.ts

export class CartItem {
  readonly id: string;
  private _productId: string;
  private _quantity: number;

  constructor(props: { id?: string; productId: string; quantity: number; cart: unknown }) {
    this.id = props.id ?? crypto.randomUUID();
    this._productId = props.productId;
    this._quantity = props.quantity;
  }

  increaseQuantity(amount: number): void {
    this._quantity += amount;
  }

  decreaseQuantity(amount: number): void {
    if (this._quantity - amount < 1) {
      throw new Error('Quantity cannot be less than 1');
    }
    this._quantity -= amount;
  }

  get productId(): string { return this._productId; }
  get quantity(): number { return this._quantity; }
}
```

### Value Objects
- **Enums:** `PascalCase` with descriptive name — `CartStatus`, `OrderStatus`, `DeliveryStatus`
- **Typed wrappers:** Descriptive noun — `ImageUrl`, `Money`, `EmailAddress`
- **File:** `<name>.enum.ts` or `<name>.vo.ts` in `domain/model/value-objects/`

```typescript
// domain/model/value-objects/cart-status.enum.ts

export enum CartStatus {
  ACTIVE = 'ACTIVE',
  CHECKED_OUT = 'CHECKED_OUT',
  ABANDONED = 'ABANDONED',
}
```

```typescript
// domain/model/value-objects/money.vo.ts

export class Money {
  private constructor(
    readonly amount: number,
    readonly currency: string,
  ) {
    if (amount < 0) throw new Error('Money amount cannot be negative');
  }

  static of(amount: number, currency = 'USD'): Money {
    return new Money(amount, currency);
  }

  add(other: Money): Money {
    if (this.currency !== other.currency) throw new Error('Currency mismatch');
    return Money.of(this.amount + other.amount, this.currency);
  }

  equals(other: Money): boolean {
    return this.amount === other.amount && this.currency === other.currency;
  }
}
```

### Commands
- **Pattern:** `[Verb][Noun]Command` — action-first naming
- **Type:** `readonly` class with constructor validation
- **File:** `<verb>-<noun>.command.ts` in `domain/model/commands/`

```typescript
// domain/model/commands/add-product-to-cart.command.ts

export class AddProductToCartCommand {
  readonly userId: string;
  readonly productId: string;
  readonly quantity: number;

  constructor(props: { userId: string; productId: string; quantity: number }) {
    if (props.quantity <= 0) {
      throw new Error('Quantity must be positive');
    }
    this.userId = props.userId;
    this.productId = props.productId;
    this.quantity = props.quantity;
  }
}
```

```typescript
// domain/model/commands/checkout-cart.command.ts

export class CheckoutCartCommand {
  readonly userId: string;

  constructor(props: { userId: string }) {
    this.userId = props.userId;
  }
}
```

### Queries
- **Pattern:** `Get[Noun]By[Criteria]Query` or `Get[Noun]Query`
- **Type:** `readonly` class
- **File:** `<get>-<noun>-by-<criteria>.query.ts` in `domain/model/queries/`

```typescript
// domain/model/queries/get-cart-by-id.query.ts

export class GetCartByIdQuery {
  readonly cartId: string;

  constructor(props: { cartId: string }) {
    this.cartId = props.cartId;
  }
}
```

```typescript
// domain/model/queries/get-products-page.query.ts

export class GetProductsPageQuery {
  readonly page: number;
  readonly limit: number;
  readonly sortBy: string;
  readonly order: 'ASC' | 'DESC';

  constructor(props: { page: number; limit: number; sortBy?: string; order?: 'ASC' | 'DESC' }) {
    this.page = props.page;
    this.limit = props.limit;
    this.sortBy = props.sortBy ?? 'createdAt';
    this.order = props.order ?? 'DESC';
  }
}
```

### Domain Service Ports (Abstract Classes)
- **Pattern:** `[Name]CommandService`, `[Name]QueryService`
- **Location:** `domain/ports/`
- **Type:** Abstract class (not interface — NestJS DI needs a runtime value for the token)

```typescript
// domain/ports/cart-command.service.ts

import { Cart } from '../model/aggregates/cart.aggregate';
import { AddProductToCartCommand } from '../model/commands/add-product-to-cart.command';
import { CheckoutCartCommand } from '../model/commands/checkout-cart.command';
import { RemoveProductFromCartCommand } from '../model/commands/remove-product-from-cart.command';

export abstract class CartCommandService {
  abstract handle(command: AddProductToCartCommand): Promise<Cart>;
  abstract handle(command: RemoveProductFromCartCommand): Promise<void>;
  abstract handle(command: CheckoutCartCommand): Promise<Cart>;
}
```

```typescript
// domain/ports/cart-query.service.ts

import { Cart } from '../model/aggregates/cart.aggregate';
import { GetCartByIdQuery } from '../model/queries/get-cart-by-id.query';
import { GetCartByUserIdQuery } from '../model/queries/get-cart-by-user-id.query';

export abstract class CartQueryService {
  abstract handle(query: GetCartByIdQuery): Promise<Cart | null>;
  abstract handle(query: GetCartByUserIdQuery): Promise<Cart | null>;
}
```

### Repository Ports (Abstract Classes)
- **Pattern:** `[Name]Repository`
- **Location:** `domain/ports/`
- **Type:** Abstract class defining persistence contract (NO TypeORM imports)

```typescript
// domain/ports/cart.repository.ts

import { Cart } from '../model/aggregates/cart.aggregate';
import { CartStatus } from '../model/value-objects/cart-status.enum';

export abstract class CartRepository {
  abstract findById(id: string): Promise<Cart | null>;
  abstract findByUserIdAndStatus(userId: string, status: CartStatus): Promise<Cart | null>;
  abstract save(cart: Cart): Promise<Cart>;
  abstract delete(id: string): Promise<void>;
}
```

### Injection Tokens
- **File:** `tokens.ts` at context root
- **Pattern:** `SCREAMING_SNAKE_CASE` string constants

```typescript
// tokens.ts

export const CART_COMMAND_SERVICE = 'CART_COMMAND_SERVICE';
export const CART_QUERY_SERVICE = 'CART_QUERY_SERVICE';
export const CART_REPOSITORY = 'CART_REPOSITORY';
export const CART_CONTEXT_FACADE = 'CART_CONTEXT_FACADE';
```

**Alternative — use the abstract class directly as token (preferred when possible):**

```typescript
// In module:
{ provide: CartRepository, useClass: TypeOrmCartRepository }

// In service constructor:
constructor(private readonly cartRepository: CartRepository) {}
```

Using abstract classes as tokens avoids string tokens entirely. Use string tokens only when you need to disambiguate or when the port is a plain interface.

### Service Implementations
- **Pattern:** `[Name]CommandServiceImpl`, `[Name]QueryServiceImpl`
- **File:** `<name>-command.service-impl.ts` in `application/command-services/`
- **Decorator:** `@Injectable()` only
- **Injection:** Constructor injection via `@Inject(TOKEN)` or abstract class tokens

```typescript
// application/command-services/cart-command.service-impl.ts

import { Injectable, Inject } from '@nestjs/common';
import { CartCommandService } from '../../domain/ports/cart-command.service';
import { CartRepository } from '../../domain/ports/cart.repository';
import { ProductContextFacade } from '../../interfaces/acl/product-context.facade';
import { PRODUCT_CONTEXT_FACADE } from '../../../products/tokens';
import { CheckoutCartCommand } from '../../domain/model/commands/checkout-cart.command';
import { Cart } from '../../domain/model/aggregates/cart.aggregate';
import { CartNotFoundException } from '../../domain/exceptions/cart-not-found.exception';
import { CartStatus } from '../../domain/model/value-objects/cart-status.enum';

@Injectable()
export class CartCommandServiceImpl extends CartCommandService {
  constructor(
    private readonly cartRepository: CartRepository,
    @Inject(PRODUCT_CONTEXT_FACADE)
    private readonly productFacade: ProductContextFacade,
  ) {
    super();
  }

  async handle(command: CheckoutCartCommand): Promise<Cart> {
    const cart = await this.cartRepository.findByUserIdAndStatus(
      command.userId,
      CartStatus.ACTIVE,
    );
    if (!cart) throw new CartNotFoundException(command.userId);

    cart.checkout(); // Domain logic in aggregate
    return this.cartRepository.save(cart);
  }
}
```

### TypeORM Entity (Infrastructure Schema) — NOT the Domain Model
- **Pattern:** `[Name]Entity` (suffixed with `Entity` to distinguish from domain)
- **File:** `<name>.orm-entity.ts` in `infrastructure/persistence/entities/`
- **Rule:** This is ONLY for ORM mapping. Domain aggregates are separate plain classes.

```typescript
// infrastructure/persistence/entities/cart.orm-entity.ts

import { Entity, PrimaryGeneratedColumn, Column, OneToMany, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { CartItemEntity } from './cart-item.orm-entity';

@Entity('carts')
export class CartEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'enum', enum: ['ACTIVE', 'CHECKED_OUT', 'ABANDONED'] })
  status: string;

  @OneToMany(() => CartItemEntity, (item) => item.cart, { cascade: true, eager: true })
  items: CartItemEntity[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
```

### Persistence Mapper (ORM Entity <-> Domain Aggregate)
- **File:** `<name>-persistence.mapper.ts` in `infrastructure/persistence/mappers/`
- **Pattern:** Static methods `toDomain()` and `toOrmEntity()`

```typescript
// infrastructure/persistence/mappers/cart-persistence.mapper.ts

import { Cart } from '../../../domain/model/aggregates/cart.aggregate';
import { CartEntity } from '../entities/cart.orm-entity';
import { CartStatus } from '../../../domain/model/value-objects/cart-status.enum';

export class CartPersistenceMapper {
  static toDomain(entity: CartEntity): Cart {
    return new Cart({
      id: entity.id,
      userId: entity.userId,
      status: entity.status as CartStatus,
      items: entity.items.map(CartItemPersistenceMapper.toDomain),
    });
  }

  static toOrmEntity(aggregate: Cart): CartEntity {
    const entity = new CartEntity();
    entity.id = aggregate.id;
    entity.userId = aggregate.userId;
    entity.status = aggregate.status;
    entity.items = aggregate.items.map(CartItemPersistenceMapper.toOrmEntity);
    return entity;
  }
}
```

### Repository Implementations
- **Pattern:** `TypeOrm[Name]Repository`
- **File:** `typeorm-<name>.repository.ts` in `infrastructure/persistence/repositories/`
- **Decorator:** `@Injectable()`
- **Extends:** Domain repository port

```typescript
// infrastructure/persistence/repositories/typeorm-cart.repository.ts

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CartRepository } from '../../../domain/ports/cart.repository';
import { Cart } from '../../../domain/model/aggregates/cart.aggregate';
import { CartEntity } from '../entities/cart.orm-entity';
import { CartPersistenceMapper } from '../mappers/cart-persistence.mapper';
import { CartStatus } from '../../../domain/model/value-objects/cart-status.enum';

@Injectable()
export class TypeOrmCartRepository extends CartRepository {
  constructor(
    @InjectRepository(CartEntity)
    private readonly ormRepo: Repository<CartEntity>,
  ) {
    super();
  }

  async findById(id: string): Promise<Cart | null> {
    const entity = await this.ormRepo.findOne({ where: { id }, relations: ['items'] });
    return entity ? CartPersistenceMapper.toDomain(entity) : null;
  }

  async findByUserIdAndStatus(userId: string, status: CartStatus): Promise<Cart | null> {
    const entity = await this.ormRepo.findOne({
      where: { userId, status },
      relations: ['items'],
    });
    return entity ? CartPersistenceMapper.toDomain(entity) : null;
  }

  async save(cart: Cart): Promise<Cart> {
    const entity = CartPersistenceMapper.toOrmEntity(cart);
    const saved = await this.ormRepo.save(entity);
    return CartPersistenceMapper.toDomain(saved);
  }

  async delete(id: string): Promise<void> {
    await this.ormRepo.delete(id);
  }
}
```

### Domain Exceptions
- **Pattern:** `[Noun]NotFoundException`, `Invalid[Noun]OperationException`
- **Extends:** Shared base exceptions
- **File:** `<name>.exception.ts` in `domain/exceptions/`

```typescript
// domain/exceptions/cart-not-found.exception.ts

import { ResourceNotFoundException } from '../../../shared/exceptions/resource-not-found.exception';

export class CartNotFoundException extends ResourceNotFoundException {
  constructor(identifier: string) {
    super('Cart', identifier);
  }
}
```

```typescript
// shared/exceptions/resource-not-found.exception.ts

import { HttpException, HttpStatus } from '@nestjs/common';

export class ResourceNotFoundException extends HttpException {
  constructor(resource: string, identifier: string) {
    super(
      {
        statusCode: HttpStatus.NOT_FOUND,
        error: 'Not Found',
        message: `${resource} with identifier "${identifier}" was not found`,
      },
      HttpStatus.NOT_FOUND,
    );
  }
}
```

### ACL Facades
- **Port (abstract class):** `[Name]ContextFacade` in `interfaces/acl/`
- **Implementation:** `[Name]ContextFacadeImpl` in `application/acl/`
- **DTO:** `[Name]Dto` in `interfaces/acl/dto/`

```typescript
// interfaces/acl/cart-context.facade.ts  (PORT — abstract class)

import { CartDto } from './dto/cart.dto';

export abstract class CartContextFacade {
  abstract getCartById(cartId: string): Promise<CartDto | null>;
  abstract getActiveCartByUserId(userId: string): Promise<CartDto | null>;
  abstract checkoutCart(userId: string, cartId: string): Promise<void>;
}
```

```typescript
// interfaces/acl/dto/cart.dto.ts

export interface CartDto {
  id: string;
  userId: string;
  status: string;
  items: CartItemDto[];
}

export interface CartItemDto {
  id: string;
  productId: string;
  quantity: number;
}
```

```typescript
// application/acl/cart-context-facade.impl.ts

import { Injectable } from '@nestjs/common';
import { CartContextFacade } from '../../interfaces/acl/cart-context.facade';
import { CartQueryService } from '../../domain/ports/cart-query.service';
import { CartDto } from '../../interfaces/acl/dto/cart.dto';
import { GetCartByIdQuery } from '../../domain/model/queries/get-cart-by-id.query';

@Injectable()
export class CartContextFacadeImpl extends CartContextFacade {
  constructor(private readonly cartQueryService: CartQueryService) {
    super();
  }

  async getCartById(cartId: string): Promise<CartDto | null> {
    const cart = await this.cartQueryService.handle(new GetCartByIdQuery({ cartId }));
    if (!cart) return null;
    return { id: cart.id, userId: cart.userId, status: cart.status, items: /* map */ [] };
  }

  // ... other methods delegate to domain services and map to DTOs
}
```

### REST Controllers
- **Pattern:** `[PluralName]Controller`
- **File:** `<plural-name>.controller.ts` in `interfaces/rest/`
- **Decorators:** `@Controller('api/v1/<plural-name>')`, `@ApiTags()`, `@UseGuards()`
- **Security:** Every method MUST have a guard (`@UseGuards(JwtAuthGuard)` at class or method level)

```typescript
// interfaces/rest/carts.controller.ts

import { Controller, Get, Post, Body, Param, UseGuards, Inject } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../../shared/infrastructure/guards/jwt-auth.guard';
import { CurrentUser } from '../../../shared/infrastructure/decorators/current-user.decorator';
import { CartCommandService } from '../../domain/ports/cart-command.service';
import { CartQueryService } from '../../domain/ports/cart-query.service';
import { CreateCartItemDto } from './dto/create-cart-item.dto';
import { CartResponseDto } from './dto/cart-response.dto';
import { CartRestMapper } from './mappers/cart-rest.mapper';
import { GetCartByUserIdQuery } from '../../domain/model/queries/get-cart-by-user-id.query';

@ApiTags('Carts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('api/v1/carts')
export class CartsController {
  constructor(
    private readonly cartCommandService: CartCommandService,
    private readonly cartQueryService: CartQueryService,
  ) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user cart' })
  async getMyCart(@CurrentUser('id') userId: string): Promise<CartResponseDto> {
    const cart = await this.cartQueryService.handle(
      new GetCartByUserIdQuery({ userId }),
    );
    return CartRestMapper.toResponse(cart);
  }

  @Post('me/items')
  @ApiOperation({ summary: 'Add item to cart' })
  async addItem(
    @CurrentUser('id') userId: string,
    @Body() dto: CreateCartItemDto,
  ): Promise<CartResponseDto> {
    const command = CartRestMapper.toAddCommand(userId, dto);
    const cart = await this.cartCommandService.handle(command);
    return CartRestMapper.toResponse(cart);
  }
}
```

### Request DTOs (class-validator)
- **File:** `<name>.dto.ts` in `interfaces/rest/dto/`
- **Rule:** Only place `class-validator` and `class-transformer` decorators here. Never in domain.

```typescript
// interfaces/rest/dto/create-cart-item.dto.ts

import { IsString, IsInt, Min, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCartItemDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  productId: string;

  @ApiProperty({ minimum: 1 })
  @IsInt()
  @Min(1)
  quantity: number;
}
```

### Mappers
- **REST pattern:** `[Name]RestMapper` — static utility class
- **File:** `<name>-rest.mapper.ts` in `interfaces/rest/mappers/`

```typescript
// interfaces/rest/mappers/cart-rest.mapper.ts

import { Cart } from '../../../domain/model/aggregates/cart.aggregate';
import { CartResponseDto } from '../dto/cart-response.dto';
import { CreateCartItemDto } from '../dto/create-cart-item.dto';
import { AddProductToCartCommand } from '../../../domain/model/commands/add-product-to-cart.command';

export class CartRestMapper {
  static toAddCommand(userId: string, dto: CreateCartItemDto): AddProductToCartCommand {
    return new AddProductToCartCommand({
      userId,
      productId: dto.productId,
      quantity: dto.quantity,
    });
  }

  static toResponse(cart: Cart): CartResponseDto {
    return {
      id: cart.id,
      userId: cart.userId,
      status: cart.status,
      items: cart.items.map((item) => ({
        id: item.id,
        productId: item.productId,
        quantity: item.quantity,
      })),
    };
  }
}
```

### GraphQL Resolvers
- **Query pattern:** `[Name]QueryResolver`
- **Mutation pattern:** `[Name]MutationResolver`
- **File:** `<name>-query.resolver.ts` in `interfaces/graphql/`

```typescript
// interfaces/graphql/cart-query.resolver.ts

import { Resolver, Query } from '@nestjs/graphql';
import { UseGuards } from '@nestjs/common';
import { GqlAuthGuard } from '../../../shared/infrastructure/guards/gql-auth.guard';
import { CurrentUser } from '../../../shared/infrastructure/decorators/current-user.decorator';
import { CartQueryService } from '../../domain/ports/cart-query.service';
import { CartGraphqlType } from './dto/cart-graphql.types';
import { CartGraphqlMapper } from './mappers/cart-graphql.mapper';
import { GetCartByUserIdQuery } from '../../domain/model/queries/get-cart-by-user-id.query';

@Resolver(() => CartGraphqlType)
export class CartQueryResolver {
  constructor(private readonly cartQueryService: CartQueryService) {}

  @UseGuards(GqlAuthGuard)
  @Query(() => CartGraphqlType, { name: 'currentUserCart', nullable: true })
  async getCurrentUserCart(@CurrentUser('id') userId: string): Promise<CartGraphqlType | null> {
    const cart = await this.cartQueryService.handle(
      new GetCartByUserIdQuery({ userId }),
    );
    return cart ? CartGraphqlMapper.toGraphqlType(cart) : null;
  }
}
```

### Event Handlers / Seeders
- **Pattern:** `[Name]SeederHandler` or `[Name]EventHandler`
- **File:** `<name>-seeder.handler.ts` in `application/event-handlers/`
- **Use case:** Seed data on bootstrap, react to domain events
- **NestJS lifecycle:** Use `OnModuleInit` or `OnApplicationBootstrap`

```typescript
// application/event-handlers/cart-seeder.handler.ts

import { Injectable, OnApplicationBootstrap } from '@nestjs/common';
import { CartCommandService } from '../../domain/ports/cart-command.service';
import { SeedCartStatusesCommand } from '../../domain/model/commands/seed-cart-statuses.command';

@Injectable()
export class CartSeederHandler implements OnApplicationBootstrap {
  constructor(private readonly cartCommandService: CartCommandService) {}

  async onApplicationBootstrap(): Promise<void> {
    await this.cartCommandService.handle(new SeedCartStatusesCommand());
  }
}
```

### NestJS Module
- **File:** `<context-name>.module.ts` at context root
- **Rule:** Binds all providers to their tokens. Exports ONLY the ACL facade.

```typescript
// carts.module.ts

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CartEntity } from './infrastructure/persistence/entities/cart.orm-entity';
import { CartItemEntity } from './infrastructure/persistence/entities/cart-item.orm-entity';
import { CartCommandService } from './domain/ports/cart-command.service';
import { CartQueryService } from './domain/ports/cart-query.service';
import { CartRepository } from './domain/ports/cart.repository';
import { CartContextFacade } from './interfaces/acl/cart-context.facade';
import { CartCommandServiceImpl } from './application/command-services/cart-command.service-impl';
import { CartQueryServiceImpl } from './application/query-services/cart-query.service-impl';
import { TypeOrmCartRepository } from './infrastructure/persistence/repositories/typeorm-cart.repository';
import { CartContextFacadeImpl } from './application/acl/cart-context-facade.impl';
import { CartsController } from './interfaces/rest/carts.controller';
import { CartQueryResolver } from './interfaces/graphql/cart-query.resolver';
import { CartMutationResolver } from './interfaces/graphql/cart-mutation.resolver';
import { CartSeederHandler } from './application/event-handlers/cart-seeder.handler';

@Module({
  imports: [TypeOrmModule.forFeature([CartEntity, CartItemEntity])],
  controllers: [CartsController],
  providers: [
    { provide: CartCommandService, useClass: CartCommandServiceImpl },
    { provide: CartQueryService, useClass: CartQueryServiceImpl },
    { provide: CartRepository, useClass: TypeOrmCartRepository },
    { provide: CartContextFacade, useClass: CartContextFacadeImpl },
    CartQueryResolver,
    CartMutationResolver,
    CartSeederHandler,
  ],
  exports: [CartContextFacade], // ONLY export the facade
})
export class CartsModule {}
```

---

## Method Naming in Services

| Operation | Command Service Method | Query Service Method |
|-----------|----------------------|---------------------|
| Create | `handle(Create...Command)` → `Promise<Entity>` | — |
| Read one | — | `handle(Get...ByIdQuery)` → `Promise<Entity \| null>` |
| Read many | — | `handle(GetAll...Query)` → `Promise<Entity[]>` |
| Read paged | — | `handle(Get...PageQuery)` → `Promise<PaginatedResult<Entity>>` |
| Update | `handle(Update...Command)` → `Promise<Entity>` | — |
| Delete | `handle(Delete...Command)` → `Promise<void>` | — |
| State change | `handle(Checkout...Command)` → `Promise<Entity>` | — |
| Seed data | `handle(Seed...Command)` → `Promise<void>` | — |

---

## Decorator Placement Rules

| Decorator | Where | Never In |
|-----------|-------|----------|
| `@Entity()`, `@Column()`, `@ManyToOne()` | Infrastructure ORM entities only | Domain aggregates/entities |
| `@Injectable()` | Application service impls, infrastructure repos/adapters, ACL facade impls | Domain |
| `@Controller()` | Interface REST controllers | — |
| `@Resolver()` | Interface GraphQL resolvers | — |
| `@UseGuards()` | Interface controllers/resolvers | Application, Domain |
| `@ApiTags()`, `@ApiProperty()` | Interface controllers/DTOs | Domain |
| `@IsString()`, `@Min()` etc. | Interface request DTOs | Domain aggregates |
| `@Inject()` | Application/infrastructure constructors | Domain |
| `@Module()` | Context root module file | — |
| `@Global()` | Shared module only | Context modules |
