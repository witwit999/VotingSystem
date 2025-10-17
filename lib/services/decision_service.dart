import 'package:dio/dio.dart';
import '../models/decision_model.dart';
import '../core/constants/api_constants.dart';
import '../core/utils/app_logger.dart';
import 'api_service.dart';

class DecisionService {
  final ApiService _apiService;

  // Store sequence counters per decision per user
  final Map<String, int> _voteSequences = {};

  DecisionService(this._apiService);

  /// Get all decisions for a session
  /// GET /sessions/{id}/decisions
  Future<List<DecisionModel>> getSessionDecisions(String sessionId) async {
    try {
      AppLogger.info(
        'DecisionService: Fetching decisions for session: $sessionId',
      );

      final response = await _apiService.get(
        ApiConstants.sessionDecisionsEndpoint(sessionId),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        AppLogger.debug('DecisionService: Parsing ${data.length} decisions');

        final decisions = <DecisionModel>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final json = data[i] as Map<String, dynamic>;
            final decision = DecisionModel.fromJson(json);
            decisions.add(decision);
            AppLogger.debug(
              '  - Decision $i: ${decision.title} (${decision.status.value})',
            );
          } catch (e) {
            AppLogger.error('DecisionService: Failed to parse decision $i', e);
          }
        }

        AppLogger.info('DecisionService: Loaded ${decisions.length} decisions');
        return decisions;
      } else {
        throw Exception('Failed to load decisions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to fetch decisions');
      AppLogger.error('  - Session ID: $sessionId');
      AppLogger.error('  - Error: ${e.response?.data}');

      if (e.response?.statusCode == 403) {
        throw Exception(
          'Not authorized to view decisions. Please join the session first.',
        );
      }

      throw Exception(errorMessage ?? 'Failed to load decisions.');
    } catch (e, stackTrace) {
      AppLogger.error('DecisionService: Unexpected error', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get decision details with tally
  /// GET /decisions/{id}
  Future<DecisionModel> getDecisionDetails(String decisionId) async {
    try {
      AppLogger.info('DecisionService: Fetching decision details: $decisionId');

      final response = await _apiService.get(
        ApiConstants.decisionDetailsEndpoint(decisionId),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final decision = DecisionModel.fromJson(data);

        AppLogger.info('DecisionService: Decision loaded: ${decision.title}');
        if (decision.tally != null) {
          AppLogger.debug(
            '  - Tally: Accept=${decision.tally!.accepted}, Deny=${decision.tally!.denied}, Abstain=${decision.tally!.abstained}',
          );
        }

        return decision;
      } else {
        throw Exception('Failed to load decision: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to fetch decision details');
      throw Exception(errorMessage ?? 'Failed to load decision.');
    } catch (e, stackTrace) {
      AppLogger.error('DecisionService: Unexpected error', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Create a new decision (admin only)
  /// POST /sessions/{id}/decisions
  Future<DecisionModel> createDecision({
    required String sessionId,
    required String title,
    String? description,
    bool allowRecast = false,
  }) async {
    try {
      AppLogger.info('DecisionService: Creating decision: $title');

      final response = await _apiService.post(
        ApiConstants.sessionDecisionsEndpoint(sessionId),
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          'allowRecast': allowRecast,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final decision = DecisionModel.fromJson(data);

        AppLogger.info('DecisionService: Decision created: ${decision.id}');
        return decision;
      } else {
        throw Exception('Failed to create decision: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to create decision');
      AppLogger.error('  - Error: ${e.response?.data}');
      throw Exception(errorMessage ?? 'Failed to create decision.');
    } catch (e, stackTrace) {
      AppLogger.error('DecisionService: Unexpected error', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Open a decision for voting (admin only)
  /// POST /decisions/{id}/open
  Future<void> openDecision(String decisionId, DateTime closeAt) async {
    try {
      AppLogger.info('DecisionService: Opening decision: $decisionId');

      final closeAtString = closeAt.toUtc().toIso8601String();
      AppLogger.debug('DecisionService: closeAt (UTC): $closeAtString');
      AppLogger.debug(
        'DecisionService: closeAt (local): ${closeAt.toIso8601String()}',
      );

      final requestBody = {'closeAt': closeAtString};
      AppLogger.debug('DecisionService: Request body: $requestBody');

      final response = await _apiService.post(
        ApiConstants.decisionOpenEndpoint(decisionId),
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('DecisionService: Decision opened successfully');
      } else {
        throw Exception('Failed to open decision: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to open decision');
      AppLogger.error('  - Response data: ${e.response?.data}');
      AppLogger.error('  - Status code: ${e.response?.statusCode}');
      throw Exception(errorMessage ?? 'Failed to open decision.');
    }
  }

  /// Close a decision (admin only)
  /// POST /decisions/{id}/close
  Future<void> closeDecision(String decisionId) async {
    try {
      AppLogger.info('DecisionService: Closing decision: $decisionId');

      final response = await _apiService.post(
        ApiConstants.decisionCloseEndpoint(decisionId),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('DecisionService: Decision closed successfully');
      } else {
        throw Exception('Failed to close decision: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to close decision');
      throw Exception(errorMessage ?? 'Failed to close decision.');
    }
  }

  /// Submit a vote on a decision
  /// POST /decisions/{id}/votes
  Future<VoteModel> submitVote({
    required String decisionId,
    required VoteChoice choice,
  }) async {
    try {
      // Get or increment sequence number for this decision
      final seq = _getNextSequence(decisionId);

      AppLogger.info(
        'DecisionService: Submitting vote on decision: $decisionId',
      );
      AppLogger.debug('  - Choice: ${choice.value}');
      AppLogger.debug('  - Sequence: $seq');

      final response = await _apiService.post(
        ApiConstants.decisionVotesEndpoint(decisionId),
        data: {'choice': choice.value, 'seq': seq},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final vote = VoteModel.fromJson(data);

        AppLogger.info('DecisionService: Vote submitted successfully');
        return vote;
      } else {
        throw Exception('Failed to submit vote: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to submit vote');
      AppLogger.error('  - Error: ${e.response?.data}');

      if (e.response?.statusCode == 403) {
        throw Exception(
          'Not authorized to vote. Please join the session first.',
        );
      } else if (e.response?.statusCode == 409) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['code'] == 'SESSION_PAUSED') {
          throw Exception('Session is paused. Voting temporarily disabled.');
        } else if (errorData is Map &&
            errorData['code'] == 'DECISION_NOT_OPEN') {
          throw Exception('Decision is not open for voting.');
        }
        throw Exception('Cannot vote at this time.');
      }

      throw Exception(errorMessage ?? 'Failed to submit vote.');
    } catch (e, stackTrace) {
      AppLogger.error('DecisionService: Unexpected error', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get all votes for a decision
  /// GET /decisions/{id}/votes
  Future<List<VoteModel>> getDecisionVotes(String decisionId) async {
    try {
      AppLogger.info(
        'DecisionService: Fetching votes for decision: $decisionId',
      );

      final response = await _apiService.get(
        ApiConstants.decisionVotesEndpoint(decisionId),
      );

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        final votes =
            data
                .map((json) => VoteModel.fromJson(json as Map<String, dynamic>))
                .toList();

        AppLogger.info('DecisionService: Loaded ${votes.length} votes');
        return votes;
      } else {
        throw Exception('Failed to load votes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _apiService.getErrorMessage(e);
      AppLogger.error('DecisionService: Failed to fetch votes');
      throw Exception(errorMessage ?? 'Failed to load votes.');
    }
  }

  /// Get next sequence number for a decision
  int _getNextSequence(String decisionId) {
    if (!_voteSequences.containsKey(decisionId)) {
      _voteSequences[decisionId] = 1;
    } else {
      _voteSequences[decisionId] = _voteSequences[decisionId]! + 1;
    }
    return _voteSequences[decisionId]!;
  }

  /// Reset sequence counter for a decision (when user first votes on it)
  void resetSequence(String decisionId) {
    _voteSequences[decisionId] = 0;
  }
}
