// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      email: json['email'] as String?,
      pictureUrl: json['picture_url'] as String?,
      personaId: json['persona_id'] as String?,
      timezone: json['timezone'] as String?,
      authType: json['auth_type'] as String?,
      profession: json['profession'] as String?,
      goals: json['goals'] as String?,
      workingPattern: json['working_pattern'] as String?,
      personalRules: json['personal_rules'] as String?,
      bio: json['bio'] as String?,
      onboardedAt: json['onboarded_at'] == null
          ? null
          : DateTime.parse(json['onboarded_at'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'email': instance.email,
      'picture_url': instance.pictureUrl,
      'persona_id': instance.personaId,
      'timezone': instance.timezone,
      'auth_type': instance.authType,
      'profession': instance.profession,
      'goals': instance.goals,
      'working_pattern': instance.workingPattern,
      'personal_rules': instance.personalRules,
      'bio': instance.bio,
      'onboarded_at': instance.onboardedAt?.toIso8601String(),
    };
