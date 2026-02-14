// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RoleType, int> role =
      GeneratedColumn<int>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(RoleType.agent.index),
      ).withConverter<RoleType>($ProfilesTable.$converterrole);
  static const VerificationMeta _codePinMeta = const VerificationMeta(
    'codePin',
  );
  @override
  late final GeneratedColumn<String> codePin = GeneratedColumn<String>(
    'code_pin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soldeCourantMeta = const VerificationMeta(
    'soldeCourant',
  );
  @override
  late final GeneratedColumn<double> soldeCourant = GeneratedColumn<double>(
    'solde_courant',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _adminIdMeta = const VerificationMeta(
    'adminId',
  );
  @override
  late final GeneratedColumn<int> adminId = GeneratedColumn<int>(
    'admin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nom,
    role,
    codePin,
    soldeCourant,
    createdAt,
    adminId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('code_pin')) {
      context.handle(
        _codePinMeta,
        codePin.isAcceptableOrUnknown(data['code_pin']!, _codePinMeta),
      );
    }
    if (data.containsKey('solde_courant')) {
      context.handle(
        _soldeCourantMeta,
        soldeCourant.isAcceptableOrUnknown(
          data['solde_courant']!,
          _soldeCourantMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('admin_id')) {
      context.handle(
        _adminIdMeta,
        adminId.isAcceptableOrUnknown(data['admin_id']!, _adminIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      role: $ProfilesTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}role'],
        )!,
      ),
      codePin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_pin'],
      ),
      soldeCourant: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}solde_courant'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      adminId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}admin_id'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RoleType, int, int> $converterrole =
      const EnumIndexConverter<RoleType>(RoleType.values);
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String nom;
  final RoleType role;
  final String? codePin;
  final double soldeCourant;
  final DateTime createdAt;
  final int? adminId;
  const Profile({
    required this.id,
    required this.nom,
    required this.role,
    this.codePin,
    required this.soldeCourant,
    required this.createdAt,
    this.adminId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    {
      map['role'] = Variable<int>($ProfilesTable.$converterrole.toSql(role));
    }
    if (!nullToAbsent || codePin != null) {
      map['code_pin'] = Variable<String>(codePin);
    }
    map['solde_courant'] = Variable<double>(soldeCourant);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || adminId != null) {
      map['admin_id'] = Variable<int>(adminId);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      nom: Value(nom),
      role: Value(role),
      codePin: codePin == null && nullToAbsent
          ? const Value.absent()
          : Value(codePin),
      soldeCourant: Value(soldeCourant),
      createdAt: Value(createdAt),
      adminId: adminId == null && nullToAbsent
          ? const Value.absent()
          : Value(adminId),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      role: $ProfilesTable.$converterrole.fromJson(
        serializer.fromJson<int>(json['role']),
      ),
      codePin: serializer.fromJson<String?>(json['codePin']),
      soldeCourant: serializer.fromJson<double>(json['soldeCourant']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      adminId: serializer.fromJson<int?>(json['adminId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'role': serializer.toJson<int>(
        $ProfilesTable.$converterrole.toJson(role),
      ),
      'codePin': serializer.toJson<String?>(codePin),
      'soldeCourant': serializer.toJson<double>(soldeCourant),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'adminId': serializer.toJson<int?>(adminId),
    };
  }

  Profile copyWith({
    int? id,
    String? nom,
    RoleType? role,
    Value<String?> codePin = const Value.absent(),
    double? soldeCourant,
    DateTime? createdAt,
    Value<int?> adminId = const Value.absent(),
  }) => Profile(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    role: role ?? this.role,
    codePin: codePin.present ? codePin.value : this.codePin,
    soldeCourant: soldeCourant ?? this.soldeCourant,
    createdAt: createdAt ?? this.createdAt,
    adminId: adminId.present ? adminId.value : this.adminId,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      role: data.role.present ? data.role.value : this.role,
      codePin: data.codePin.present ? data.codePin.value : this.codePin,
      soldeCourant: data.soldeCourant.present
          ? data.soldeCourant.value
          : this.soldeCourant,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      adminId: data.adminId.present ? data.adminId.value : this.adminId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('role: $role, ')
          ..write('codePin: $codePin, ')
          ..write('soldeCourant: $soldeCourant, ')
          ..write('createdAt: $createdAt, ')
          ..write('adminId: $adminId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nom, role, codePin, soldeCourant, createdAt, adminId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.role == this.role &&
          other.codePin == this.codePin &&
          other.soldeCourant == this.soldeCourant &&
          other.createdAt == this.createdAt &&
          other.adminId == this.adminId);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> nom;
  final Value<RoleType> role;
  final Value<String?> codePin;
  final Value<double> soldeCourant;
  final Value<DateTime> createdAt;
  final Value<int?> adminId;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.role = const Value.absent(),
    this.codePin = const Value.absent(),
    this.soldeCourant = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.adminId = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    this.role = const Value.absent(),
    this.codePin = const Value.absent(),
    this.soldeCourant = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.adminId = const Value.absent(),
  }) : nom = Value(nom);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<int>? role,
    Expression<String>? codePin,
    Expression<double>? soldeCourant,
    Expression<DateTime>? createdAt,
    Expression<int>? adminId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (role != null) 'role': role,
      if (codePin != null) 'code_pin': codePin,
      if (soldeCourant != null) 'solde_courant': soldeCourant,
      if (createdAt != null) 'created_at': createdAt,
      if (adminId != null) 'admin_id': adminId,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<RoleType>? role,
    Value<String?>? codePin,
    Value<double>? soldeCourant,
    Value<DateTime>? createdAt,
    Value<int?>? adminId,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      role: role ?? this.role,
      codePin: codePin ?? this.codePin,
      soldeCourant: soldeCourant ?? this.soldeCourant,
      createdAt: createdAt ?? this.createdAt,
      adminId: adminId ?? this.adminId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(
        $ProfilesTable.$converterrole.toSql(role.value),
      );
    }
    if (codePin.present) {
      map['code_pin'] = Variable<String>(codePin.value);
    }
    if (soldeCourant.present) {
      map['solde_courant'] = Variable<double>(soldeCourant.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (adminId.present) {
      map['admin_id'] = Variable<int>(adminId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('role: $role, ')
          ..write('codePin: $codePin, ')
          ..write('soldeCourant: $soldeCourant, ')
          ..write('createdAt: $createdAt, ')
          ..write('adminId: $adminId')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _horodatageMeta = const VerificationMeta(
    'horodatage',
  );
  @override
  late final GeneratedColumn<DateTime> horodatage = GeneratedColumn<DateTime>(
    'horodatage',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OperatorType, int> operateur =
      GeneratedColumn<int>(
        'operateur',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<OperatorType>($TransactionsTable.$converteroperateur);
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _montantMeta = const VerificationMeta(
    'montant',
  );
  @override
  late final GeneratedColumn<double> montant = GeneratedColumn<double>(
    'montant',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionStatus, int> statut =
      GeneratedColumn<int>(
        'statut',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: Constant(TransactionStatus.reussi.index),
      ).withConverter<TransactionStatus>($TransactionsTable.$converterstatut);
  static const VerificationMeta _bonusMeta = const VerificationMeta('bonus');
  @override
  late final GeneratedColumn<double> bonus = GeneratedColumn<double>(
    'bonus',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _numeroClientMeta = const VerificationMeta(
    'numeroClient',
  );
  @override
  late final GeneratedColumn<String> numeroClient = GeneratedColumn<String>(
    'numero_client',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
  );
  static const VerificationMeta _estSaisieManuelleMeta = const VerificationMeta(
    'estSaisieManuelle',
  );
  @override
  late final GeneratedColumn<bool> estSaisieManuelle = GeneratedColumn<bool>(
    'est_saisie_manuelle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("est_saisie_manuelle" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta(
    'agentId',
  );
  @override
  late final GeneratedColumn<int> agentId = GeneratedColumn<int>(
    'agent_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    horodatage,
    operateur,
    type,
    montant,
    statut,
    bonus,
    numeroClient,
    reference,
    estSaisieManuelle,
    agentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('horodatage')) {
      context.handle(
        _horodatageMeta,
        horodatage.isAcceptableOrUnknown(data['horodatage']!, _horodatageMeta),
      );
    }
    if (data.containsKey('montant')) {
      context.handle(
        _montantMeta,
        montant.isAcceptableOrUnknown(data['montant']!, _montantMeta),
      );
    } else if (isInserting) {
      context.missing(_montantMeta);
    }
    if (data.containsKey('bonus')) {
      context.handle(
        _bonusMeta,
        bonus.isAcceptableOrUnknown(data['bonus']!, _bonusMeta),
      );
    }
    if (data.containsKey('numero_client')) {
      context.handle(
        _numeroClientMeta,
        numeroClient.isAcceptableOrUnknown(
          data['numero_client']!,
          _numeroClientMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    } else if (isInserting) {
      context.missing(_referenceMeta);
    }
    if (data.containsKey('est_saisie_manuelle')) {
      context.handle(
        _estSaisieManuelleMeta,
        estSaisieManuelle.isAcceptableOrUnknown(
          data['est_saisie_manuelle']!,
          _estSaisieManuelleMeta,
        ),
      );
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      horodatage: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}horodatage'],
      )!,
      operateur: $TransactionsTable.$converteroperateur.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}operateur'],
        )!,
      ),
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      montant: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant'],
      )!,
      statut: $TransactionsTable.$converterstatut.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}statut'],
        )!,
      ),
      bonus: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bonus'],
      )!,
      numeroClient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_client'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      )!,
      estSaisieManuelle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}est_saisie_manuelle'],
      )!,
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}agent_id'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperatorType, int, int> $converteroperateur =
      const EnumIndexConverter<OperatorType>(OperatorType.values);
  static JsonTypeConverter2<TransactionType, int, int> $convertertype =
      const EnumIndexConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<TransactionStatus, int, int> $converterstatut =
      const EnumIndexConverter<TransactionStatus>(TransactionStatus.values);
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final DateTime horodatage;
  final OperatorType operateur;
  final TransactionType type;
  final double montant;
  final TransactionStatus statut;
  final double bonus;
  final String? numeroClient;
  final String reference;
  final bool estSaisieManuelle;
  final int agentId;
  const Transaction({
    required this.id,
    required this.horodatage,
    required this.operateur,
    required this.type,
    required this.montant,
    required this.statut,
    required this.bonus,
    this.numeroClient,
    required this.reference,
    required this.estSaisieManuelle,
    required this.agentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['horodatage'] = Variable<DateTime>(horodatage);
    {
      map['operateur'] = Variable<int>(
        $TransactionsTable.$converteroperateur.toSql(operateur),
      );
    }
    {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['montant'] = Variable<double>(montant);
    {
      map['statut'] = Variable<int>(
        $TransactionsTable.$converterstatut.toSql(statut),
      );
    }
    map['bonus'] = Variable<double>(bonus);
    if (!nullToAbsent || numeroClient != null) {
      map['numero_client'] = Variable<String>(numeroClient);
    }
    map['reference'] = Variable<String>(reference);
    map['est_saisie_manuelle'] = Variable<bool>(estSaisieManuelle);
    map['agent_id'] = Variable<int>(agentId);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      horodatage: Value(horodatage),
      operateur: Value(operateur),
      type: Value(type),
      montant: Value(montant),
      statut: Value(statut),
      bonus: Value(bonus),
      numeroClient: numeroClient == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroClient),
      reference: Value(reference),
      estSaisieManuelle: Value(estSaisieManuelle),
      agentId: Value(agentId),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      horodatage: serializer.fromJson<DateTime>(json['horodatage']),
      operateur: $TransactionsTable.$converteroperateur.fromJson(
        serializer.fromJson<int>(json['operateur']),
      ),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      montant: serializer.fromJson<double>(json['montant']),
      statut: $TransactionsTable.$converterstatut.fromJson(
        serializer.fromJson<int>(json['statut']),
      ),
      bonus: serializer.fromJson<double>(json['bonus']),
      numeroClient: serializer.fromJson<String?>(json['numeroClient']),
      reference: serializer.fromJson<String>(json['reference']),
      estSaisieManuelle: serializer.fromJson<bool>(json['estSaisieManuelle']),
      agentId: serializer.fromJson<int>(json['agentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'horodatage': serializer.toJson<DateTime>(horodatage),
      'operateur': serializer.toJson<int>(
        $TransactionsTable.$converteroperateur.toJson(operateur),
      ),
      'type': serializer.toJson<int>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'montant': serializer.toJson<double>(montant),
      'statut': serializer.toJson<int>(
        $TransactionsTable.$converterstatut.toJson(statut),
      ),
      'bonus': serializer.toJson<double>(bonus),
      'numeroClient': serializer.toJson<String?>(numeroClient),
      'reference': serializer.toJson<String>(reference),
      'estSaisieManuelle': serializer.toJson<bool>(estSaisieManuelle),
      'agentId': serializer.toJson<int>(agentId),
    };
  }

  Transaction copyWith({
    int? id,
    DateTime? horodatage,
    OperatorType? operateur,
    TransactionType? type,
    double? montant,
    TransactionStatus? statut,
    double? bonus,
    Value<String?> numeroClient = const Value.absent(),
    String? reference,
    bool? estSaisieManuelle,
    int? agentId,
  }) => Transaction(
    id: id ?? this.id,
    horodatage: horodatage ?? this.horodatage,
    operateur: operateur ?? this.operateur,
    type: type ?? this.type,
    montant: montant ?? this.montant,
    statut: statut ?? this.statut,
    bonus: bonus ?? this.bonus,
    numeroClient: numeroClient.present ? numeroClient.value : this.numeroClient,
    reference: reference ?? this.reference,
    estSaisieManuelle: estSaisieManuelle ?? this.estSaisieManuelle,
    agentId: agentId ?? this.agentId,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      horodatage: data.horodatage.present
          ? data.horodatage.value
          : this.horodatage,
      operateur: data.operateur.present ? data.operateur.value : this.operateur,
      type: data.type.present ? data.type.value : this.type,
      montant: data.montant.present ? data.montant.value : this.montant,
      statut: data.statut.present ? data.statut.value : this.statut,
      bonus: data.bonus.present ? data.bonus.value : this.bonus,
      numeroClient: data.numeroClient.present
          ? data.numeroClient.value
          : this.numeroClient,
      reference: data.reference.present ? data.reference.value : this.reference,
      estSaisieManuelle: data.estSaisieManuelle.present
          ? data.estSaisieManuelle.value
          : this.estSaisieManuelle,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('horodatage: $horodatage, ')
          ..write('operateur: $operateur, ')
          ..write('type: $type, ')
          ..write('montant: $montant, ')
          ..write('statut: $statut, ')
          ..write('bonus: $bonus, ')
          ..write('numeroClient: $numeroClient, ')
          ..write('reference: $reference, ')
          ..write('estSaisieManuelle: $estSaisieManuelle, ')
          ..write('agentId: $agentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    horodatage,
    operateur,
    type,
    montant,
    statut,
    bonus,
    numeroClient,
    reference,
    estSaisieManuelle,
    agentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.horodatage == this.horodatage &&
          other.operateur == this.operateur &&
          other.type == this.type &&
          other.montant == this.montant &&
          other.statut == this.statut &&
          other.bonus == this.bonus &&
          other.numeroClient == this.numeroClient &&
          other.reference == this.reference &&
          other.estSaisieManuelle == this.estSaisieManuelle &&
          other.agentId == this.agentId);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<DateTime> horodatage;
  final Value<OperatorType> operateur;
  final Value<TransactionType> type;
  final Value<double> montant;
  final Value<TransactionStatus> statut;
  final Value<double> bonus;
  final Value<String?> numeroClient;
  final Value<String> reference;
  final Value<bool> estSaisieManuelle;
  final Value<int> agentId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.horodatage = const Value.absent(),
    this.operateur = const Value.absent(),
    this.type = const Value.absent(),
    this.montant = const Value.absent(),
    this.statut = const Value.absent(),
    this.bonus = const Value.absent(),
    this.numeroClient = const Value.absent(),
    this.reference = const Value.absent(),
    this.estSaisieManuelle = const Value.absent(),
    this.agentId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    this.horodatage = const Value.absent(),
    required OperatorType operateur,
    required TransactionType type,
    required double montant,
    this.statut = const Value.absent(),
    this.bonus = const Value.absent(),
    this.numeroClient = const Value.absent(),
    required String reference,
    this.estSaisieManuelle = const Value.absent(),
    required int agentId,
  }) : operateur = Value(operateur),
       type = Value(type),
       montant = Value(montant),
       reference = Value(reference),
       agentId = Value(agentId);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<DateTime>? horodatage,
    Expression<int>? operateur,
    Expression<int>? type,
    Expression<double>? montant,
    Expression<int>? statut,
    Expression<double>? bonus,
    Expression<String>? numeroClient,
    Expression<String>? reference,
    Expression<bool>? estSaisieManuelle,
    Expression<int>? agentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (horodatage != null) 'horodatage': horodatage,
      if (operateur != null) 'operateur': operateur,
      if (type != null) 'type': type,
      if (montant != null) 'montant': montant,
      if (statut != null) 'statut': statut,
      if (bonus != null) 'bonus': bonus,
      if (numeroClient != null) 'numero_client': numeroClient,
      if (reference != null) 'reference': reference,
      if (estSaisieManuelle != null) 'est_saisie_manuelle': estSaisieManuelle,
      if (agentId != null) 'agent_id': agentId,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? horodatage,
    Value<OperatorType>? operateur,
    Value<TransactionType>? type,
    Value<double>? montant,
    Value<TransactionStatus>? statut,
    Value<double>? bonus,
    Value<String?>? numeroClient,
    Value<String>? reference,
    Value<bool>? estSaisieManuelle,
    Value<int>? agentId,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      horodatage: horodatage ?? this.horodatage,
      operateur: operateur ?? this.operateur,
      type: type ?? this.type,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      bonus: bonus ?? this.bonus,
      numeroClient: numeroClient ?? this.numeroClient,
      reference: reference ?? this.reference,
      estSaisieManuelle: estSaisieManuelle ?? this.estSaisieManuelle,
      agentId: agentId ?? this.agentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (horodatage.present) {
      map['horodatage'] = Variable<DateTime>(horodatage.value);
    }
    if (operateur.present) {
      map['operateur'] = Variable<int>(
        $TransactionsTable.$converteroperateur.toSql(operateur.value),
      );
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (montant.present) {
      map['montant'] = Variable<double>(montant.value);
    }
    if (statut.present) {
      map['statut'] = Variable<int>(
        $TransactionsTable.$converterstatut.toSql(statut.value),
      );
    }
    if (bonus.present) {
      map['bonus'] = Variable<double>(bonus.value);
    }
    if (numeroClient.present) {
      map['numero_client'] = Variable<String>(numeroClient.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (estSaisieManuelle.present) {
      map['est_saisie_manuelle'] = Variable<bool>(estSaisieManuelle.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<int>(agentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('horodatage: $horodatage, ')
          ..write('operateur: $operateur, ')
          ..write('type: $type, ')
          ..write('montant: $montant, ')
          ..write('statut: $statut, ')
          ..write('bonus: $bonus, ')
          ..write('numeroClient: $numeroClient, ')
          ..write('reference: $reference, ')
          ..write('estSaisieManuelle: $estSaisieManuelle, ')
          ..write('agentId: $agentId')
          ..write(')'))
        .toString();
  }
}

class $LogActivitiesTable extends LogActivities
    with TableInfo<$LogActivitiesTable, LogActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _adminIdMeta = const VerificationMeta(
    'adminId',
  );
  @override
  late final GeneratedColumn<int> adminId = GeneratedColumn<int>(
    'admin_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _agentIdMeta = const VerificationMeta(
    'agentId',
  );
  @override
  late final GeneratedColumn<int> agentId = GeneratedColumn<int>(
    'agent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES profiles (id)',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ancienSoldeMeta = const VerificationMeta(
    'ancienSolde',
  );
  @override
  late final GeneratedColumn<double> ancienSolde = GeneratedColumn<double>(
    'ancien_solde',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nouveauSoldeMeta = const VerificationMeta(
    'nouveauSolde',
  );
  @override
  late final GeneratedColumn<double> nouveauSolde = GeneratedColumn<double>(
    'nouveau_solde',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horodatageMeta = const VerificationMeta(
    'horodatage',
  );
  @override
  late final GeneratedColumn<DateTime> horodatage = GeneratedColumn<DateTime>(
    'horodatage',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    adminId,
    agentId,
    action,
    ancienSolde,
    nouveauSolde,
    horodatage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogActivity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('admin_id')) {
      context.handle(
        _adminIdMeta,
        adminId.isAcceptableOrUnknown(data['admin_id']!, _adminIdMeta),
      );
    }
    if (data.containsKey('agent_id')) {
      context.handle(
        _agentIdMeta,
        agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('ancien_solde')) {
      context.handle(
        _ancienSoldeMeta,
        ancienSolde.isAcceptableOrUnknown(
          data['ancien_solde']!,
          _ancienSoldeMeta,
        ),
      );
    }
    if (data.containsKey('nouveau_solde')) {
      context.handle(
        _nouveauSoldeMeta,
        nouveauSolde.isAcceptableOrUnknown(
          data['nouveau_solde']!,
          _nouveauSoldeMeta,
        ),
      );
    }
    if (data.containsKey('horodatage')) {
      context.handle(
        _horodatageMeta,
        horodatage.isAcceptableOrUnknown(data['horodatage']!, _horodatageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogActivity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      adminId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}admin_id'],
      ),
      agentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}agent_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      ancienSolde: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ancien_solde'],
      ),
      nouveauSolde: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}nouveau_solde'],
      ),
      horodatage: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}horodatage'],
      )!,
    );
  }

  @override
  $LogActivitiesTable createAlias(String alias) {
    return $LogActivitiesTable(attachedDatabase, alias);
  }
}

class LogActivity extends DataClass implements Insertable<LogActivity> {
  final int id;
  final int? adminId;
  final int? agentId;
  final String action;
  final double? ancienSolde;
  final double? nouveauSolde;
  final DateTime horodatage;
  const LogActivity({
    required this.id,
    this.adminId,
    this.agentId,
    required this.action,
    this.ancienSolde,
    this.nouveauSolde,
    required this.horodatage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || adminId != null) {
      map['admin_id'] = Variable<int>(adminId);
    }
    if (!nullToAbsent || agentId != null) {
      map['agent_id'] = Variable<int>(agentId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || ancienSolde != null) {
      map['ancien_solde'] = Variable<double>(ancienSolde);
    }
    if (!nullToAbsent || nouveauSolde != null) {
      map['nouveau_solde'] = Variable<double>(nouveauSolde);
    }
    map['horodatage'] = Variable<DateTime>(horodatage);
    return map;
  }

  LogActivitiesCompanion toCompanion(bool nullToAbsent) {
    return LogActivitiesCompanion(
      id: Value(id),
      adminId: adminId == null && nullToAbsent
          ? const Value.absent()
          : Value(adminId),
      agentId: agentId == null && nullToAbsent
          ? const Value.absent()
          : Value(agentId),
      action: Value(action),
      ancienSolde: ancienSolde == null && nullToAbsent
          ? const Value.absent()
          : Value(ancienSolde),
      nouveauSolde: nouveauSolde == null && nullToAbsent
          ? const Value.absent()
          : Value(nouveauSolde),
      horodatage: Value(horodatage),
    );
  }

  factory LogActivity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogActivity(
      id: serializer.fromJson<int>(json['id']),
      adminId: serializer.fromJson<int?>(json['adminId']),
      agentId: serializer.fromJson<int?>(json['agentId']),
      action: serializer.fromJson<String>(json['action']),
      ancienSolde: serializer.fromJson<double?>(json['ancienSolde']),
      nouveauSolde: serializer.fromJson<double?>(json['nouveauSolde']),
      horodatage: serializer.fromJson<DateTime>(json['horodatage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'adminId': serializer.toJson<int?>(adminId),
      'agentId': serializer.toJson<int?>(agentId),
      'action': serializer.toJson<String>(action),
      'ancienSolde': serializer.toJson<double?>(ancienSolde),
      'nouveauSolde': serializer.toJson<double?>(nouveauSolde),
      'horodatage': serializer.toJson<DateTime>(horodatage),
    };
  }

  LogActivity copyWith({
    int? id,
    Value<int?> adminId = const Value.absent(),
    Value<int?> agentId = const Value.absent(),
    String? action,
    Value<double?> ancienSolde = const Value.absent(),
    Value<double?> nouveauSolde = const Value.absent(),
    DateTime? horodatage,
  }) => LogActivity(
    id: id ?? this.id,
    adminId: adminId.present ? adminId.value : this.adminId,
    agentId: agentId.present ? agentId.value : this.agentId,
    action: action ?? this.action,
    ancienSolde: ancienSolde.present ? ancienSolde.value : this.ancienSolde,
    nouveauSolde: nouveauSolde.present ? nouveauSolde.value : this.nouveauSolde,
    horodatage: horodatage ?? this.horodatage,
  );
  LogActivity copyWithCompanion(LogActivitiesCompanion data) {
    return LogActivity(
      id: data.id.present ? data.id.value : this.id,
      adminId: data.adminId.present ? data.adminId.value : this.adminId,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      action: data.action.present ? data.action.value : this.action,
      ancienSolde: data.ancienSolde.present
          ? data.ancienSolde.value
          : this.ancienSolde,
      nouveauSolde: data.nouveauSolde.present
          ? data.nouveauSolde.value
          : this.nouveauSolde,
      horodatage: data.horodatage.present
          ? data.horodatage.value
          : this.horodatage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogActivity(')
          ..write('id: $id, ')
          ..write('adminId: $adminId, ')
          ..write('agentId: $agentId, ')
          ..write('action: $action, ')
          ..write('ancienSolde: $ancienSolde, ')
          ..write('nouveauSolde: $nouveauSolde, ')
          ..write('horodatage: $horodatage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    adminId,
    agentId,
    action,
    ancienSolde,
    nouveauSolde,
    horodatage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogActivity &&
          other.id == this.id &&
          other.adminId == this.adminId &&
          other.agentId == this.agentId &&
          other.action == this.action &&
          other.ancienSolde == this.ancienSolde &&
          other.nouveauSolde == this.nouveauSolde &&
          other.horodatage == this.horodatage);
}

class LogActivitiesCompanion extends UpdateCompanion<LogActivity> {
  final Value<int> id;
  final Value<int?> adminId;
  final Value<int?> agentId;
  final Value<String> action;
  final Value<double?> ancienSolde;
  final Value<double?> nouveauSolde;
  final Value<DateTime> horodatage;
  const LogActivitiesCompanion({
    this.id = const Value.absent(),
    this.adminId = const Value.absent(),
    this.agentId = const Value.absent(),
    this.action = const Value.absent(),
    this.ancienSolde = const Value.absent(),
    this.nouveauSolde = const Value.absent(),
    this.horodatage = const Value.absent(),
  });
  LogActivitiesCompanion.insert({
    this.id = const Value.absent(),
    this.adminId = const Value.absent(),
    this.agentId = const Value.absent(),
    required String action,
    this.ancienSolde = const Value.absent(),
    this.nouveauSolde = const Value.absent(),
    this.horodatage = const Value.absent(),
  }) : action = Value(action);
  static Insertable<LogActivity> custom({
    Expression<int>? id,
    Expression<int>? adminId,
    Expression<int>? agentId,
    Expression<String>? action,
    Expression<double>? ancienSolde,
    Expression<double>? nouveauSolde,
    Expression<DateTime>? horodatage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adminId != null) 'admin_id': adminId,
      if (agentId != null) 'agent_id': agentId,
      if (action != null) 'action': action,
      if (ancienSolde != null) 'ancien_solde': ancienSolde,
      if (nouveauSolde != null) 'nouveau_solde': nouveauSolde,
      if (horodatage != null) 'horodatage': horodatage,
    });
  }

  LogActivitiesCompanion copyWith({
    Value<int>? id,
    Value<int?>? adminId,
    Value<int?>? agentId,
    Value<String>? action,
    Value<double?>? ancienSolde,
    Value<double?>? nouveauSolde,
    Value<DateTime>? horodatage,
  }) {
    return LogActivitiesCompanion(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      agentId: agentId ?? this.agentId,
      action: action ?? this.action,
      ancienSolde: ancienSolde ?? this.ancienSolde,
      nouveauSolde: nouveauSolde ?? this.nouveauSolde,
      horodatage: horodatage ?? this.horodatage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (adminId.present) {
      map['admin_id'] = Variable<int>(adminId.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<int>(agentId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (ancienSolde.present) {
      map['ancien_solde'] = Variable<double>(ancienSolde.value);
    }
    if (nouveauSolde.present) {
      map['nouveau_solde'] = Variable<double>(nouveauSolde.value);
    }
    if (horodatage.present) {
      map['horodatage'] = Variable<DateTime>(horodatage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('adminId: $adminId, ')
          ..write('agentId: $agentId, ')
          ..write('action: $action, ')
          ..write('ancienSolde: $ancienSolde, ')
          ..write('nouveauSolde: $nouveauSolde, ')
          ..write('horodatage: $horodatage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $LogActivitiesTable logActivities = $LogActivitiesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    transactions,
    logActivities,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String nom,
      Value<RoleType> role,
      Value<String?> codePin,
      Value<double> soldeCourant,
      Value<DateTime> createdAt,
      Value<int?> adminId,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<RoleType> role,
      Value<String?> codePin,
      Value<double> soldeCourant,
      Value<DateTime> createdAt,
      Value<int?> adminId,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _adminIdTable(_$AppDatabase db) => db.profiles
      .createAlias($_aliasNameGenerator(db.profiles.adminId, db.profiles.id));

  $$ProfilesTableProcessedTableManager? get adminId {
    final $_column = $_itemColumn<int>('admin_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_adminIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.transactions.agentId),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.agentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LogActivitiesTable, List<LogActivity>>
  _logsAsAdminTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.logActivities,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.logActivities.adminId),
  );

  $$LogActivitiesTableProcessedTableManager get logsAsAdmin {
    final manager = $$LogActivitiesTableTableManager(
      $_db,
      $_db.logActivities,
    ).filter((f) => f.adminId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_logsAsAdminTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LogActivitiesTable, List<LogActivity>>
  _logsAsAgentTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.logActivities,
    aliasName: $_aliasNameGenerator(db.profiles.id, db.logActivities.agentId),
  );

  $$LogActivitiesTableProcessedTableManager get logsAsAgent {
    final manager = $$LogActivitiesTableTableManager(
      $_db,
      $_db.logActivities,
    ).filter((f) => f.agentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_logsAsAgentTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RoleType, RoleType, int> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get codePin => $composableBuilder(
    column: $table.codePin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get soldeCourant => $composableBuilder(
    column: $table.soldeCourant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get adminId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adminId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.agentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> logsAsAdmin(
    Expression<bool> Function($$LogActivitiesTableFilterComposer f) f,
  ) {
    final $$LogActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logActivities,
      getReferencedColumn: (t) => t.adminId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.logActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> logsAsAgent(
    Expression<bool> Function($$LogActivitiesTableFilterComposer f) f,
  ) {
    final $$LogActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logActivities,
      getReferencedColumn: (t) => t.agentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.logActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codePin => $composableBuilder(
    column: $table.codePin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get soldeCourant => $composableBuilder(
    column: $table.soldeCourant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get adminId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adminId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RoleType, int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get codePin =>
      $composableBuilder(column: $table.codePin, builder: (column) => column);

  GeneratedColumn<double> get soldeCourant => $composableBuilder(
    column: $table.soldeCourant,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get adminId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adminId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.agentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> logsAsAdmin<T extends Object>(
    Expression<T> Function($$LogActivitiesTableAnnotationComposer a) f,
  ) {
    final $$LogActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logActivities,
      getReferencedColumn: (t) => t.adminId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.logActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> logsAsAgent<T extends Object>(
    Expression<T> Function($$LogActivitiesTableAnnotationComposer a) f,
  ) {
    final $$LogActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logActivities,
      getReferencedColumn: (t) => t.agentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.logActivities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({
            bool adminId,
            bool transactionsRefs,
            bool logsAsAdmin,
            bool logsAsAgent,
          })
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<RoleType> role = const Value.absent(),
                Value<String?> codePin = const Value.absent(),
                Value<double> soldeCourant = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> adminId = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                nom: nom,
                role: role,
                codePin: codePin,
                soldeCourant: soldeCourant,
                createdAt: createdAt,
                adminId: adminId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                Value<RoleType> role = const Value.absent(),
                Value<String?> codePin = const Value.absent(),
                Value<double> soldeCourant = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> adminId = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                nom: nom,
                role: role,
                codePin: codePin,
                soldeCourant: soldeCourant,
                createdAt: createdAt,
                adminId: adminId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                adminId = false,
                transactionsRefs = false,
                logsAsAdmin = false,
                logsAsAgent = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                    if (logsAsAdmin) db.logActivities,
                    if (logsAsAgent) db.logActivities,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (adminId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.adminId,
                                    referencedTable: $$ProfilesTableReferences
                                        ._adminIdTable(db),
                                    referencedColumn: $$ProfilesTableReferences
                                        ._adminIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.agentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (logsAsAdmin)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          LogActivity
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._logsAsAdminTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).logsAsAdmin,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.adminId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (logsAsAgent)
                        await $_getPrefetchedData<
                          Profile,
                          $ProfilesTable,
                          LogActivity
                        >(
                          currentTable: table,
                          referencedTable: $$ProfilesTableReferences
                              ._logsAsAgentTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProfilesTableReferences(
                                db,
                                table,
                                p0,
                              ).logsAsAgent,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.agentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({
        bool adminId,
        bool transactionsRefs,
        bool logsAsAdmin,
        bool logsAsAgent,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<DateTime> horodatage,
      required OperatorType operateur,
      required TransactionType type,
      required double montant,
      Value<TransactionStatus> statut,
      Value<double> bonus,
      Value<String?> numeroClient,
      required String reference,
      Value<bool> estSaisieManuelle,
      required int agentId,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<DateTime> horodatage,
      Value<OperatorType> operateur,
      Value<TransactionType> type,
      Value<double> montant,
      Value<TransactionStatus> statut,
      Value<double> bonus,
      Value<String?> numeroClient,
      Value<String> reference,
      Value<bool> estSaisieManuelle,
      Value<int> agentId,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _agentIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.transactions.agentId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager get agentId {
    final $_column = $_itemColumn<int>('agent_id')!;

    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_agentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get horodatage => $composableBuilder(
    column: $table.horodatage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OperatorType, OperatorType, int>
  get operateur => $composableBuilder(
    column: $table.operateur,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get montant => $composableBuilder(
    column: $table.montant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionStatus, TransactionStatus, int>
  get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get bonus => $composableBuilder(
    column: $table.bonus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numeroClient => $composableBuilder(
    column: $table.numeroClient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get estSaisieManuelle => $composableBuilder(
    column: $table.estSaisieManuelle,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get agentId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get horodatage => $composableBuilder(
    column: $table.horodatage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operateur => $composableBuilder(
    column: $table.operateur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montant => $composableBuilder(
    column: $table.montant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bonus => $composableBuilder(
    column: $table.bonus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeroClient => $composableBuilder(
    column: $table.numeroClient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get estSaisieManuelle => $composableBuilder(
    column: $table.estSaisieManuelle,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get agentId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get horodatage => $composableBuilder(
    column: $table.horodatage,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OperatorType, int> get operateur =>
      $composableBuilder(column: $table.operateur, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get montant =>
      $composableBuilder(column: $table.montant, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionStatus, int> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<double> get bonus =>
      $composableBuilder(column: $table.bonus, builder: (column) => column);

  GeneratedColumn<String> get numeroClient => $composableBuilder(
    column: $table.numeroClient,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<bool> get estSaisieManuelle => $composableBuilder(
    column: $table.estSaisieManuelle,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get agentId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool agentId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> horodatage = const Value.absent(),
                Value<OperatorType> operateur = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<double> montant = const Value.absent(),
                Value<TransactionStatus> statut = const Value.absent(),
                Value<double> bonus = const Value.absent(),
                Value<String?> numeroClient = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<bool> estSaisieManuelle = const Value.absent(),
                Value<int> agentId = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                horodatage: horodatage,
                operateur: operateur,
                type: type,
                montant: montant,
                statut: statut,
                bonus: bonus,
                numeroClient: numeroClient,
                reference: reference,
                estSaisieManuelle: estSaisieManuelle,
                agentId: agentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> horodatage = const Value.absent(),
                required OperatorType operateur,
                required TransactionType type,
                required double montant,
                Value<TransactionStatus> statut = const Value.absent(),
                Value<double> bonus = const Value.absent(),
                Value<String?> numeroClient = const Value.absent(),
                required String reference,
                Value<bool> estSaisieManuelle = const Value.absent(),
                required int agentId,
              }) => TransactionsCompanion.insert(
                id: id,
                horodatage: horodatage,
                operateur: operateur,
                type: type,
                montant: montant,
                statut: statut,
                bonus: bonus,
                numeroClient: numeroClient,
                reference: reference,
                estSaisieManuelle: estSaisieManuelle,
                agentId: agentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({agentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (agentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.agentId,
                                referencedTable: $$TransactionsTableReferences
                                    ._agentIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._agentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool agentId})
    >;
typedef $$LogActivitiesTableCreateCompanionBuilder =
    LogActivitiesCompanion Function({
      Value<int> id,
      Value<int?> adminId,
      Value<int?> agentId,
      required String action,
      Value<double?> ancienSolde,
      Value<double?> nouveauSolde,
      Value<DateTime> horodatage,
    });
typedef $$LogActivitiesTableUpdateCompanionBuilder =
    LogActivitiesCompanion Function({
      Value<int> id,
      Value<int?> adminId,
      Value<int?> agentId,
      Value<String> action,
      Value<double?> ancienSolde,
      Value<double?> nouveauSolde,
      Value<DateTime> horodatage,
    });

final class $$LogActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $LogActivitiesTable, LogActivity> {
  $$LogActivitiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProfilesTable _adminIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.logActivities.adminId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager? get adminId {
    final $_column = $_itemColumn<int>('admin_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_adminIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProfilesTable _agentIdTable(_$AppDatabase db) =>
      db.profiles.createAlias(
        $_aliasNameGenerator(db.logActivities.agentId, db.profiles.id),
      );

  $$ProfilesTableProcessedTableManager? get agentId {
    final $_column = $_itemColumn<int>('agent_id');
    if ($_column == null) return null;
    final manager = $$ProfilesTableTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_agentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LogActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LogActivitiesTable> {
  $$LogActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ancienSolde => $composableBuilder(
    column: $table.ancienSolde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nouveauSolde => $composableBuilder(
    column: $table.nouveauSolde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get horodatage => $composableBuilder(
    column: $table.horodatage,
    builder: (column) => ColumnFilters(column),
  );

  $$ProfilesTableFilterComposer get adminId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adminId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableFilterComposer get agentId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LogActivitiesTable> {
  $$LogActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ancienSolde => $composableBuilder(
    column: $table.ancienSolde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nouveauSolde => $composableBuilder(
    column: $table.nouveauSolde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get horodatage => $composableBuilder(
    column: $table.horodatage,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProfilesTableOrderingComposer get adminId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adminId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableOrderingComposer get agentId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogActivitiesTable> {
  $$LogActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<double> get ancienSolde => $composableBuilder(
    column: $table.ancienSolde,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nouveauSolde => $composableBuilder(
    column: $table.nouveauSolde,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get horodatage => $composableBuilder(
    column: $table.horodatage,
    builder: (column) => column,
  );

  $$ProfilesTableAnnotationComposer get adminId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adminId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProfilesTableAnnotationComposer get agentId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.agentId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogActivitiesTable,
          LogActivity,
          $$LogActivitiesTableFilterComposer,
          $$LogActivitiesTableOrderingComposer,
          $$LogActivitiesTableAnnotationComposer,
          $$LogActivitiesTableCreateCompanionBuilder,
          $$LogActivitiesTableUpdateCompanionBuilder,
          (LogActivity, $$LogActivitiesTableReferences),
          LogActivity,
          PrefetchHooks Function({bool adminId, bool agentId})
        > {
  $$LogActivitiesTableTableManager(_$AppDatabase db, $LogActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> adminId = const Value.absent(),
                Value<int?> agentId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<double?> ancienSolde = const Value.absent(),
                Value<double?> nouveauSolde = const Value.absent(),
                Value<DateTime> horodatage = const Value.absent(),
              }) => LogActivitiesCompanion(
                id: id,
                adminId: adminId,
                agentId: agentId,
                action: action,
                ancienSolde: ancienSolde,
                nouveauSolde: nouveauSolde,
                horodatage: horodatage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> adminId = const Value.absent(),
                Value<int?> agentId = const Value.absent(),
                required String action,
                Value<double?> ancienSolde = const Value.absent(),
                Value<double?> nouveauSolde = const Value.absent(),
                Value<DateTime> horodatage = const Value.absent(),
              }) => LogActivitiesCompanion.insert(
                id: id,
                adminId: adminId,
                agentId: agentId,
                action: action,
                ancienSolde: ancienSolde,
                nouveauSolde: nouveauSolde,
                horodatage: horodatage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LogActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({adminId = false, agentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (adminId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.adminId,
                                referencedTable: $$LogActivitiesTableReferences
                                    ._adminIdTable(db),
                                referencedColumn: $$LogActivitiesTableReferences
                                    ._adminIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (agentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.agentId,
                                referencedTable: $$LogActivitiesTableReferences
                                    ._agentIdTable(db),
                                referencedColumn: $$LogActivitiesTableReferences
                                    ._agentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LogActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogActivitiesTable,
      LogActivity,
      $$LogActivitiesTableFilterComposer,
      $$LogActivitiesTableOrderingComposer,
      $$LogActivitiesTableAnnotationComposer,
      $$LogActivitiesTableCreateCompanionBuilder,
      $$LogActivitiesTableUpdateCompanionBuilder,
      (LogActivity, $$LogActivitiesTableReferences),
      LogActivity,
      PrefetchHooks Function({bool adminId, bool agentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$LogActivitiesTableTableManager get logActivities =>
      $$LogActivitiesTableTableManager(_db, _db.logActivities);
}
