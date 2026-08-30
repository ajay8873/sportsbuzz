-- ==============================================================================
-- SPORTSBUZZ: UNIVERSITY FEST LIVE SCORING & STREAMING DATABASE SCHEMA
-- Compatible with Supabase PostgreSQL & Realtime Broadcast Engine
-- Zero Emojis throughout database schema and seed comments
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. ENUM TYPES
DO $$ BEGIN
    CREATE TYPE sport_category AS ENUM ('INDOOR', 'OUTDOOR');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE scoring_model_type AS ENUM (
        'RUN_BASED',
        'TIME_BASED',
        'SET_BASED',
        'BOARD_BASED',
        'MATCH_BASED'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE match_status_type AS ENUM ('SCHEDULED', 'LIVE', 'COMPLETED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. EVENTS TABLE
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    share_slug TEXT NOT NULL UNIQUE,
    description TEXT,
    venue TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. SPORTS TABLE
CREATE TABLE IF NOT EXISTS sports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    category sport_category NOT NULL,
    scoring_model scoring_model_type NOT NULL,
    icon_name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. MATCHES (FIXTURES) TABLE
CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sport_id UUID NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    team_a TEXT NOT NULL,
    team_b TEXT NOT NULL,
    status match_status_type NOT NULL DEFAULT 'SCHEDULED',
    scheduled_time TIMESTAMPTZ NOT NULL,
    stream_url TEXT,
    venue TEXT,
    stage TEXT DEFAULT 'League Match',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. MATCH STATE (JSONB SCOREBOARD) TABLE
CREATE TABLE IF NOT EXISTS match_state (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL UNIQUE REFERENCES matches(id) ON DELETE CASCADE,
    current_score JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. PERFORMANCE & HIGH-CONCURRENCY INDEXES
CREATE INDEX IF NOT EXISTS idx_events_share_slug ON events(share_slug);
CREATE INDEX IF NOT EXISTS idx_sports_event_id ON sports(event_id);
CREATE INDEX IF NOT EXISTS idx_sports_category ON sports(category);
CREATE INDEX IF NOT EXISTS idx_matches_sport_id ON matches(sport_id);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_scheduled_time ON matches(scheduled_time);
CREATE INDEX IF NOT EXISTS idx_match_state_match_id ON match_state(match_id);
CREATE INDEX IF NOT EXISTS idx_match_state_updated_at ON match_state(updated_at);

-- 8. AUTOMATIC UPDATED_AT TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_match_state_updated_at ON match_state;
CREATE TRIGGER trg_match_state_updated_at
BEFORE UPDATE ON match_state
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 9. AUTOMATIC MATCH_STATE INITIALIZATION TRIGGER
CREATE OR REPLACE FUNCTION auto_create_match_state()
RETURNS TRIGGER AS $$
DECLARE
    v_scoring_model scoring_model_type;
    v_initial_score JSONB;
BEGIN
    SELECT scoring_model INTO v_scoring_model FROM sports WHERE id = NEW.sport_id;

    IF v_scoring_model = 'RUN_BASED' THEN
        v_initial_score := jsonb_build_object(
            'type', 'RUN_BASED',
            'runs', 0,
            'wickets', 0,
            'overs', 0.0,
            'balls', 0,
            'battingTeam', NEW.team_a,
            'bowlingTeam', NEW.team_b,
            'striker', 'Batsman 1',
            'strikerRuns', 0,
            'strikerBalls', 0,
            'nonStriker', 'Batsman 2',
            'nonStrikerRuns', 0,
            'nonStrikerBalls', 0,
            'currentBowler', 'Bowler 1',
            'bowlerOvers', 0.0,
            'bowlerRunsConceded', 0,
            'bowlerWickets', 0,
            'wides', 0,
            'noBalls', 0,
            'byes', 0,
            'legByes', 0,
            'extras', 0,
            'innings', '1st Innings',
            'recentBalls', '[]'::jsonb
        );
    ELSIF v_scoring_model = 'TIME_BASED' THEN
        v_initial_score := jsonb_build_object(
            'type', 'TIME_BASED',
            'teamAScore', 0,
            'teamBScore', 0,
            'elapsedSeconds', 0,
            'isClockRunning', false,
            'period', '1st Half',
            'teamAFouls', 0,
            'teamBFouls', 0,
            'teamAYellowCards', 0,
            'teamBYellowCards', 0,
            'teamARedCards', 0,
            'teamBRedCards', 0,
            'timeline', '[]'::jsonb
        );
    ELSIF v_scoring_model = 'SET_BASED' THEN
        v_initial_score := jsonb_build_object(
            'type', 'SET_BASED',
            'currentSetPointsA', 0,
            'currentSetPointsB', 0,
            'currentSetNumber', 1,
            'setsWonA', 0,
            'setsWonB', 0,
            'maxSets', 3,
            'completedSets', '[]'::jsonb,
            'servingTeam', 'TEAM_A',
            'isDeuce', false
        );
    ELSIF v_scoring_model = 'BOARD_BASED' THEN
        v_initial_score := jsonb_build_object(
            'type', 'BOARD_BASED',
            'matchPointsA', 0.0,
            'matchPointsB', 0.0,
            'boardNumber', 1,
            'timeRemainingSecondsA', 600,
            'timeRemainingSecondsB', 600,
            'isClockRunning', false,
            'activeTurn', 'PLAYER_A',
            'statusDetail', 'In Progress',
            'movesCount', 0,
            'notationHistory', '[]'::jsonb,
            'carromCoinsA', 0,
            'carromCoinsB', 0,
            'queenCovered', false
        );
    ELSE
        v_initial_score := jsonb_build_object(
            'type', 'MATCH_BASED',
            'roundsWonA', 0,
            'roundsWonB', 0,
            'totalRounds', 3,
            'tugOfWarRounds', '[]'::jsonb,
            'athleticsEntries', '[]'::jsonb,
            'subCategory', 'TUG_OF_WAR',
            'eventStage', 'Final'
        );
    END IF;

    INSERT INTO match_state (match_id, current_score)
    VALUES (NEW.id, v_initial_score)
    ON CONFLICT (match_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_matches_after_insert ON matches;
CREATE TRIGGER trg_matches_after_insert
AFTER INSERT ON matches
FOR EACH ROW
EXECUTE FUNCTION auto_create_match_state();

-- 10. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE sports ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_state ENABLE ROW LEVEL SECURITY;

-- Anonymous public read policies (for web/mobile viewers)
CREATE POLICY "Public events are viewable by everyone" ON events FOR SELECT USING (true);
CREATE POLICY "Public sports are viewable by everyone" ON sports FOR SELECT USING (true);
CREATE POLICY "Public matches are viewable by everyone" ON matches FOR SELECT USING (true);
CREATE POLICY "Public match_state is viewable by everyone" ON match_state FOR SELECT USING (true);

-- Anonymous/Authenticated insert and update policies (open for campus admin/scorers or restricted by auth)
CREATE POLICY "Enable insert for events" ON events FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for events" ON events FOR UPDATE USING (true);
CREATE POLICY "Enable delete for events" ON events FOR DELETE USING (true);

CREATE POLICY "Enable insert for sports" ON sports FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for sports" ON sports FOR UPDATE USING (true);
CREATE POLICY "Enable delete for sports" ON sports FOR DELETE USING (true);

CREATE POLICY "Enable insert for matches" ON matches FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for matches" ON matches FOR UPDATE USING (true);
CREATE POLICY "Enable delete for matches" ON matches FOR DELETE USING (true);

CREATE POLICY "Enable insert for match_state" ON match_state FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for match_state" ON match_state FOR UPDATE USING (true);
CREATE POLICY "Enable delete for match_state" ON match_state FOR DELETE USING (true);

-- 11. SUPABASE REALTIME PUBLICATION
ALTER PUBLICATION supabase_realtime ADD TABLE match_state;
ALTER PUBLICATION supabase_realtime ADD TABLE matches;

-- 12. COMPREHENSIVE SEED DATA (PLEXUS 2026)
DO $$
DECLARE
    v_event_id UUID;
    v_cricket_id UUID;
    v_football_id UUID;
    v_volleyball_id UUID;
    v_chess_id UUID;
    v_tug_id UUID;
    v_match_cricket UUID;
    v_match_football UUID;
    v_match_volleyball UUID;
    v_match_chess UUID;
    v_match_tug UUID;
BEGIN
    -- Create Master Event
    INSERT INTO events (name, start_date, end_date, share_slug, description, venue)
    VALUES (
        'PLEXUS 2026',
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '4 days',
        'plexus-2026',
        'Annual Inter-Department Athletic Meet & University Sports Fest',
        'University Sports Complex & Stadium'
    )
    ON CONFLICT (share_slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_event_id;

    -- Add Outdoor & Indoor Sports
    INSERT INTO sports (event_id, name, category, scoring_model, icon_name)
    VALUES (v_event_id, 'Men Cricket Championship', 'OUTDOOR', 'RUN_BASED', 'trophy')
    RETURNING id INTO v_cricket_id;

    INSERT INTO sports (event_id, name, category, scoring_model, icon_name)
    VALUES (v_event_id, 'Inter-Dept Football Cup', 'OUTDOOR', 'TIME_BASED', 'activity')
    RETURNING id INTO v_football_id;

    INSERT INTO sports (event_id, name, category, scoring_model, icon_name)
    VALUES (v_event_id, 'Volleyball Smash League', 'INDOOR', 'SET_BASED', 'shield')
    RETURNING id INTO v_volleyball_id;

    INSERT INTO sports (event_id, name, category, scoring_model, icon_name)
    VALUES (v_event_id, 'Grandmaster Chess Challenge', 'INDOOR', 'BOARD_BASED', 'crown')
    RETURNING id INTO v_chess_id;

    INSERT INTO sports (event_id, name, category, scoring_model, icon_name)
    VALUES (v_event_id, 'Athletics Tug of War', 'OUTDOOR', 'MATCH_BASED', 'swords')
    RETURNING id INTO v_tug_id;

    -- Schedule Matches
    INSERT INTO matches (sport_id, title, team_a, team_b, status, scheduled_time, stream_url, venue, stage)
    VALUES (
        v_cricket_id,
        'CS Dept vs Mech Dept',
        'CS Dept',
        'Mech Dept',
        'LIVE',
        NOW() - INTERVAL '45 minutes',
        'https://www.youtube.com/watch?v=live_stream_cricket',
        'Main Cricket Oval',
        'Finals'
    )
    RETURNING id INTO v_match_cricket;

    INSERT INTO matches (sport_id, title, team_a, team_b, status, scheduled_time, stream_url, venue, stage)
    VALUES (
        v_football_id,
        'Civil Dept vs Electrical Dept',
        'Civil Dept',
        'Electrical Dept',
        'LIVE',
        NOW() - INTERVAL '25 minutes',
        'https://www.youtube.com/watch?v=live_stream_football',
        'Football Stadium',
        'Semi-Final 1'
    )
    RETURNING id INTO v_match_football;

    INSERT INTO matches (sport_id, title, team_a, team_b, status, scheduled_time, stream_url, venue, stage)
    VALUES (
        v_volleyball_id,
        'IT Warriors vs Biotech Titans',
        'IT Warriors',
        'Biotech Titans',
        'SCHEDULED',
        NOW() + INTERVAL '2 hours',
        NULL,
        'Indoor Arena Court 1',
        'Quarter-Final'
    )
    RETURNING id INTO v_match_volleyball;

    INSERT INTO matches (sport_id, title, team_a, team_b, status, scheduled_time, stream_url, venue, stage)
    VALUES (
        v_chess_id,
        'A. Sharma (CS) vs R. Gupta (ECE)',
        'A. Sharma (CS)',
        'R. Gupta (ECE)',
        'LIVE',
        NOW() - INTERVAL '15 minutes',
        NULL,
        'Student Centre Hall B',
        'Round 5'
    )
    RETURNING id INTO v_match_chess;

    INSERT INTO matches (sport_id, title, team_a, team_b, status, scheduled_time, stream_url, venue, stage)
    VALUES (
        v_tug_id,
        'Hostel 1 vs Hostel 4',
        'Hostel 1',
        'Hostel 4',
        'COMPLETED',
        NOW() - INTERVAL '3 hours',
        NULL,
        'Athletic Track Arena',
        'Finals'
    )
    RETURNING id INTO v_match_tug;

    -- Update Live Cricket Score State
    UPDATE match_state
    SET current_score = jsonb_build_object(
        'type', 'RUN_BASED',
        'runs', 148,
        'wickets', 3,
        'overs', 15.4,
        'balls', 4,
        'battingTeam', 'CS Dept',
        'bowlingTeam', 'Mech Dept',
        'striker', 'Aakash Roy',
        'strikerRuns', 62,
        'strikerBalls', 36,
        'nonStriker', 'Karan Patel',
        'nonStrikerRuns', 34,
        'nonStrikerBalls', 24,
        'currentBowler', 'Suraj Nair',
        'bowlerOvers', 3.4,
        'bowlerRunsConceded', 28,
        'bowlerWickets', 1,
        'wides', 4,
        'noBalls', 1,
        'byes', 2,
        'legByes', 1,
        'extras', 8,
        'target', 185,
        'innings', '2nd Innings',
        'recentBalls', '["1", "4", "0", "6", "1", "W"]'::jsonb
    )
    WHERE match_id = v_match_cricket;

    -- Update Live Football Score State
    UPDATE match_state
    SET current_score = jsonb_build_object(
        'type', 'TIME_BASED',
        'teamAScore', 2,
        'teamBScore', 1,
        'elapsedSeconds', 3420,
        'isClockRunning', true,
        'period', '2nd Half',
        'teamAFouls', 5,
        'teamBFouls', 7,
        'teamAYellowCards', 1,
        'teamBYellowCards', 2,
        'teamARedCards', 0,
        'teamBRedCards', 0,
        'timeline', '[
            {"id": "e1", "timestampSeconds": 1320, "eventType": "GOAL", "team": "TEAM_A", "playerName": "Nitin Shah", "notes": "Header from corner"},
            {"id": "e2", "timestampSeconds": 2100, "eventType": "GOAL", "team": "TEAM_B", "playerName": "Rohan Dsouza", "notes": "Penalty kick"},
            {"id": "e3", "timestampSeconds": 3120, "eventType": "GOAL", "team": "TEAM_A", "playerName": "Nitin Shah", "notes": "Long range strike"}
        ]'::jsonb
    )
    WHERE match_id = v_match_football;

    -- Update Live Chess Score State
    UPDATE match_state
    SET current_score = jsonb_build_object(
        'type', 'BOARD_BASED',
        'matchPointsA', 0.5,
        'matchPointsB', 0.5,
        'boardNumber', 1,
        'timeRemainingSecondsA', 412,
        'timeRemainingSecondsB', 298,
        'isClockRunning', true,
        'activeTurn', 'PLAYER_B',
        'statusDetail', 'In Progress',
        'movesCount', 28,
        'notationHistory', '["1. e4 e5", "2. Nf3 Nc6", "3. Bb5 a6"]'::jsonb,
        'carromCoinsA', 0,
        'carromCoinsB', 0,
        'queenCovered', false
    )
    WHERE match_id = v_match_chess;

    -- Update Completed Tug of War Score State
    UPDATE match_state
    SET current_score = jsonb_build_object(
        'type', 'MATCH_BASED',
        'overallWinner', 'Hostel 1',
        'roundsWonA', 2,
        'roundsWonB', 1,
        'totalRounds', 3,
        'subCategory', 'TUG_OF_WAR',
        'eventStage', 'Finals',
        'tugOfWarRounds', '[
            {"roundNumber": 1, "winner": "TEAM_A", "durationSeconds": 48},
            {"roundNumber": 2, "winner": "TEAM_B", "durationSeconds": 62},
            {"roundNumber": 3, "winner": "TEAM_A", "durationSeconds": 39}
        ]'::jsonb,
        'athleticsEntries', '[]'::jsonb
    )
    WHERE match_id = v_match_tug;

END $$;
