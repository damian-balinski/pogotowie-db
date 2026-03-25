--
-- PostgreSQL database dump
--

\restrict ttofGV5du579NwuKTpuSeiyNTIQyGjDGJU6uJ6hKpMhcb2wwrfL7Wurdpq7XeTl

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fn_aktualizuj_status_karetki(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_aktualizuj_status_karetki() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

    -- NOWY WYJAZD -> karetka w trasie
    IF TG_OP = 'INSERT' THEN
        UPDATE karetki
        SET status = 'W_TRASIE'
        WHERE id_karetki = NEW.id_karetki;

    -- POWRÓT KARETKI
    ELSIF TG_OP = 'UPDATE'
       AND NEW.czas_powrotu IS NOT NULL
       AND OLD.czas_powrotu IS NULL THEN

        UPDATE karetki
        SET status = 'DOSTEPNA'
        WHERE id_karetki = NEW.id_karetki;

    END IF;

    RETURN NEW;

END;
$$;


ALTER FUNCTION public.fn_aktualizuj_status_karetki() OWNER TO postgres;

--
-- Name: fn_loguj_zmiane_statusu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_loguj_zmiane_statusu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Reaguj TYLKO gdy status faktycznie się zmienił
    IF NEW.status <> OLD.status THEN
        INSERT INTO log_wezwan (id_wezwania, stary_status, nowy_status,
                                zmieniono_o, uzytkownik)
        VALUES (OLD.id_wezwania, OLD.status, NEW.status,
                NOW(), CURRENT_USER);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_loguj_zmiane_statusu() OWNER TO postgres;

--
-- Name: fn_waliduj_sklad_zespolu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_waliduj_sklad_zespolu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_liczba_czlonkow INTEGER;  -- zmienna przechowująca liczbę członków zespołu
BEGIN
    -- policz członków zespołu przypisanego do nowego wyjazdu
    SELECT COUNT(*) INTO v_liczba_czlonkow
    FROM sklad_zespolu
    WHERE id_zespolu = NEW.id_zespolu;

    -- jeśli mniej niż 2, przerwij INSERT i zgłoś błąd
    IF v_liczba_czlonkow < 2 THEN
        RAISE EXCEPTION
            'Zespół % ma tylko % członków. Wymagane minimum to 2.',
            NEW.id_zespolu, v_liczba_czlonkow;
    END IF;

    RETURN NEW;  -- pozwala na wykonanie INSERT jeśli warunek spełniony
END;
$$;


ALTER FUNCTION public.fn_waliduj_sklad_zespolu() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dyspozytorzy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dyspozytorzy (
    id_dyspozytora integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    telefon character varying(15),
    email character varying(100)
);


ALTER TABLE public.dyspozytorzy OWNER TO postgres;

--
-- Name: dyspozytorzy_id_dyspozytora_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dyspozytorzy_id_dyspozytora_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dyspozytorzy_id_dyspozytora_seq OWNER TO postgres;

--
-- Name: dyspozytorzy_id_dyspozytora_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dyspozytorzy_id_dyspozytora_seq OWNED BY public.dyspozytorzy.id_dyspozytora;


--
-- Name: dyspozytorzy_zmiany; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dyspozytorzy_zmiany (
    id integer NOT NULL,
    id_dyspozytora integer NOT NULL,
    id_zmiany integer NOT NULL
);


ALTER TABLE public.dyspozytorzy_zmiany OWNER TO postgres;

--
-- Name: dyspozytorzy_zmiany_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dyspozytorzy_zmiany_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dyspozytorzy_zmiany_id_seq OWNER TO postgres;

--
-- Name: dyspozytorzy_zmiany_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dyspozytorzy_zmiany_id_seq OWNED BY public.dyspozytorzy_zmiany.id;


--
-- Name: karetki; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.karetki (
    id_karetki integer NOT NULL,
    nr_rejestracyjny character varying(10) NOT NULL,
    typ_karetki character varying(1) NOT NULL,
    rok_produkcji integer,
    status character varying(15) DEFAULT 'DOSTEPNA'::character varying NOT NULL,
    CONSTRAINT karetki_rok_produkcji_check CHECK (((rok_produkcji >= 1990) AND (rok_produkcji <= 2030))),
    CONSTRAINT karetki_status_check CHECK (((status)::text = ANY ((ARRAY['DOSTEPNA'::character varying, 'W_TRASIE'::character varying, 'W_SERWISIE'::character varying])::text[]))),
    CONSTRAINT karetki_typ_karetki_check CHECK (((typ_karetki)::text = ANY ((ARRAY['P'::character varying, 'S'::character varying, 'R'::character varying])::text[])))
);


ALTER TABLE public.karetki OWNER TO postgres;

--
-- Name: karetki_id_karetki_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.karetki_id_karetki_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.karetki_id_karetki_seq OWNER TO postgres;

--
-- Name: karetki_id_karetki_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.karetki_id_karetki_seq OWNED BY public.karetki.id_karetki;


--
-- Name: katalog_swiadczen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.katalog_swiadczen (
    id_swiadczenia integer NOT NULL,
    kod_procedury character varying(20) NOT NULL,
    nazwa character varying(200) NOT NULL,
    kategoria character varying(100),
    opis text
);


ALTER TABLE public.katalog_swiadczen OWNER TO postgres;

--
-- Name: katalog_swiadczen_id_swiadczenia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.katalog_swiadczen_id_swiadczenia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.katalog_swiadczen_id_swiadczenia_seq OWNER TO postgres;

--
-- Name: katalog_swiadczen_id_swiadczenia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.katalog_swiadczen_id_swiadczenia_seq OWNED BY public.katalog_swiadczen.id_swiadczenia;


--
-- Name: log_wezwan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_wezwan (
    id integer NOT NULL,
    id_wezwania integer NOT NULL,
    stary_status character varying(20),
    nowy_status character varying(20),
    zmieniono_o timestamp without time zone DEFAULT now(),
    uzytkownik character varying(100) DEFAULT CURRENT_USER
);


ALTER TABLE public.log_wezwan OWNER TO postgres;

--
-- Name: log_wezwan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_wezwan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_wezwan_id_seq OWNER TO postgres;

--
-- Name: log_wezwan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_wezwan_id_seq OWNED BY public.log_wezwan.id;


--
-- Name: pacjenci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pacjenci (
    id_pacjenta integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    pesel character varying(11),
    data_urodzenia date,
    plec character varying(1),
    nr_telefonu character varying(15),
    adres character varying(200),
    CONSTRAINT pacjenci_plec_check CHECK (((plec)::text = ANY ((ARRAY['M'::character varying, 'K'::character varying, 'N'::character varying])::text[])))
);


ALTER TABLE public.pacjenci OWNER TO postgres;

--
-- Name: pacjenci_id_pacjenta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pacjenci_id_pacjenta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pacjenci_id_pacjenta_seq OWNER TO postgres;

--
-- Name: pacjenci_id_pacjenta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pacjenci_id_pacjenta_seq OWNED BY public.pacjenci.id_pacjenta;


--
-- Name: pracownicy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pracownicy (
    id_pracownika integer NOT NULL,
    imie character varying(50) NOT NULL,
    nazwisko character varying(50) NOT NULL,
    pesel character varying(11) NOT NULL,
    stanowisko character varying(50) NOT NULL,
    nr_uprawnien character varying(30),
    CONSTRAINT pracownicy_stanowisko_check CHECK (((stanowisko)::text = ANY ((ARRAY['ratownik_medyczny'::character varying, 'lekarz'::character varying, 'kierowca'::character varying])::text[])))
);


ALTER TABLE public.pracownicy OWNER TO postgres;

--
-- Name: pracownicy_id_pracownika_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pracownicy_id_pracownika_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pracownicy_id_pracownika_seq OWNER TO postgres;

--
-- Name: pracownicy_id_pracownika_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pracownicy_id_pracownika_seq OWNED BY public.pracownicy.id_pracownika;


--
-- Name: sklad_zespolu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sklad_zespolu (
    id integer NOT NULL,
    id_zespolu integer NOT NULL,
    id_pracownika integer NOT NULL,
    rola_w_zespole character varying(50) NOT NULL
);


ALTER TABLE public.sklad_zespolu OWNER TO postgres;

--
-- Name: sklad_zespolu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sklad_zespolu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sklad_zespolu_id_seq OWNER TO postgres;

--
-- Name: sklad_zespolu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sklad_zespolu_id_seq OWNED BY public.sklad_zespolu.id;


--
-- Name: udzielona_pomoc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.udzielona_pomoc (
    id integer NOT NULL,
    id_wyjazdu integer NOT NULL,
    id_pacjenta integer NOT NULL,
    id_swiadczenia integer NOT NULL,
    godzina_wykonania timestamp without time zone,
    wynik character varying(100),
    uwagi text
);


ALTER TABLE public.udzielona_pomoc OWNER TO postgres;

--
-- Name: udzielona_pomoc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.udzielona_pomoc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.udzielona_pomoc_id_seq OWNER TO postgres;

--
-- Name: udzielona_pomoc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.udzielona_pomoc_id_seq OWNED BY public.udzielona_pomoc.id;


--
-- Name: wezwania; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wezwania (
    id_wezwania integer NOT NULL,
    id_dyspozytora integer NOT NULL,
    data_zgloszenia date NOT NULL,
    godzina_zgloszenia time without time zone NOT NULL,
    adres character varying(200) NOT NULL,
    miasto character varying(100) NOT NULL,
    priorytet character varying(2) NOT NULL,
    opis_zdarzenia text,
    status character varying(20) DEFAULT 'NOWE'::character varying NOT NULL,
    CONSTRAINT wezwania_priorytet_check CHECK (((priorytet)::text = ANY ((ARRAY['P1'::character varying, 'P2'::character varying, 'P3'::character varying])::text[]))),
    CONSTRAINT wezwania_status_check CHECK (((status)::text = ANY ((ARRAY['NOWE'::character varying, 'W_REALIZACJI'::character varying, 'ZAKONCZONE'::character varying, 'ANULOWANE'::character varying])::text[])))
);


ALTER TABLE public.wezwania OWNER TO postgres;

--
-- Name: wyjazd_pacjent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wyjazd_pacjent (
    id integer NOT NULL,
    id_wyjazdu integer NOT NULL,
    id_pacjenta integer NOT NULL,
    stan_przy_przyjeciu text,
    stan_przy_przekazaniu text,
    miejsce_przekazania character varying(200)
);


ALTER TABLE public.wyjazd_pacjent OWNER TO postgres;

--
-- Name: wyjazdy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wyjazdy (
    id_wyjazdu integer NOT NULL,
    id_wezwania integer NOT NULL,
    id_karetki integer NOT NULL,
    id_zespolu integer NOT NULL,
    czas_wyjazdu timestamp without time zone NOT NULL,
    czas_przybycia timestamp without time zone,
    czas_powrotu timestamp without time zone,
    miejsce_docelowe character varying(200),
    uwagi text
);


ALTER TABLE public.wyjazdy OWNER TO postgres;

--
-- Name: v_historia_pacjenta; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_historia_pacjenta AS
 SELECT p.id_pacjenta,
    concat(p.imie, ' ', p.nazwisko) AS pacjent,
    p.pesel,
    p.data_urodzenia,
    p.plec,
    wez.data_zgloszenia,
    wez.adres AS miejsce_zdarzenia,
    wez.priorytet,
    wp.stan_przy_przyjeciu,
    wp.stan_przy_przekazaniu,
    wp.miejsce_przekazania,
    ks.kod_procedury,
    ks.nazwa AS procedura,
    ks.kategoria AS kategoria_procedury,
    up.godzina_wykonania,
    up.wynik,
    up.uwagi AS uwagi_procedury
   FROM (((((public.pacjenci p
     JOIN public.udzielona_pomoc up ON ((p.id_pacjenta = up.id_pacjenta)))
     JOIN public.katalog_swiadczen ks ON ((up.id_swiadczenia = ks.id_swiadczenia)))
     JOIN public.wyjazdy wyj ON ((up.id_wyjazdu = wyj.id_wyjazdu)))
     JOIN public.wezwania wez ON ((wyj.id_wezwania = wez.id_wezwania)))
     LEFT JOIN public.wyjazd_pacjent wp ON (((wp.id_wyjazdu = wyj.id_wyjazdu) AND (wp.id_pacjenta = p.id_pacjenta))));


ALTER VIEW public.v_historia_pacjenta OWNER TO postgres;

--
-- Name: v_obciazenie_dyspozytorni; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_obciazenie_dyspozytorni AS
 SELECT concat(d.imie, ' ', d.nazwisko) AS dyspozytor,
    to_char((wez.data_zgloszenia)::timestamp with time zone, 'YYYY-MM'::text) AS miesiac,
    count(wez.id_wezwania) AS liczba_zgloszen,
    count(
        CASE
            WHEN ((wez.priorytet)::text = 'P1'::text) THEN 1
            ELSE NULL::integer
        END) AS p1,
    count(
        CASE
            WHEN ((wez.priorytet)::text = 'P2'::text) THEN 1
            ELSE NULL::integer
        END) AS p2,
    count(
        CASE
            WHEN ((wez.priorytet)::text = 'P3'::text) THEN 1
            ELSE NULL::integer
        END) AS p3,
    count(
        CASE
            WHEN ((wez.status)::text = 'ZAKONCZONE'::text) THEN 1
            ELSE NULL::integer
        END) AS zakonczone
   FROM (public.dyspozytorzy d
     LEFT JOIN public.wezwania wez ON ((d.id_dyspozytora = wez.id_dyspozytora)))
  GROUP BY d.id_dyspozytora, d.imie, d.nazwisko, (to_char((wez.data_zgloszenia)::timestamp with time zone, 'YYYY-MM'::text));


ALTER VIEW public.v_obciazenie_dyspozytorni OWNER TO postgres;

--
-- Name: zespoly; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zespoly (
    id_zespolu integer NOT NULL,
    nazwa_zespolu character varying(100) NOT NULL,
    typ_zespolu character varying(20) NOT NULL,
    CONSTRAINT zespoly_typ_zespolu_check CHECK (((typ_zespolu)::text = ANY ((ARRAY['podstawowy'::character varying, 'specjalistyczny'::character varying, 'reanimacyjny'::character varying])::text[])))
);


ALTER TABLE public.zespoly OWNER TO postgres;

--
-- Name: v_szczegoly_wyjazdu; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_szczegoly_wyjazdu AS
 SELECT w.id_wyjazdu,
    wez.id_wezwania,
    wez.data_zgloszenia,
    wez.godzina_zgloszenia,
    wez.adres AS adres_zdarzenia,
    wez.miasto,
    wez.priorytet,
    wez.opis_zdarzenia,
    wez.status AS status_wezwania,
    concat(d.imie, ' ', d.nazwisko) AS dyspozytor,
    k.nr_rejestracyjny,
    k.typ_karetki,
    z.nazwa_zespolu,
    z.typ_zespolu,
    w.czas_wyjazdu,
    w.czas_przybycia,
    w.czas_powrotu,
        CASE
            WHEN (w.czas_powrotu IS NOT NULL) THEN round((EXTRACT(epoch FROM (w.czas_powrotu - w.czas_wyjazdu)) / (60)::numeric))
            ELSE NULL::numeric
        END AS czas_interwencji_min,
    w.miejsce_docelowe,
    w.uwagi
   FROM ((((public.wyjazdy w
     JOIN public.wezwania wez ON ((w.id_wezwania = wez.id_wezwania)))
     JOIN public.karetki k ON ((w.id_karetki = k.id_karetki)))
     JOIN public.zespoly z ON ((w.id_zespolu = z.id_zespolu)))
     JOIN public.dyspozytorzy d ON ((wez.id_dyspozytora = d.id_dyspozytora)));


ALTER VIEW public.v_szczegoly_wyjazdu OWNER TO postgres;

--
-- Name: wezwania_id_wezwania_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wezwania_id_wezwania_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wezwania_id_wezwania_seq OWNER TO postgres;

--
-- Name: wezwania_id_wezwania_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wezwania_id_wezwania_seq OWNED BY public.wezwania.id_wezwania;


--
-- Name: wyjazd_pacjent_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wyjazd_pacjent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wyjazd_pacjent_id_seq OWNER TO postgres;

--
-- Name: wyjazd_pacjent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wyjazd_pacjent_id_seq OWNED BY public.wyjazd_pacjent.id;


--
-- Name: wyjazdy_id_wyjazdu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wyjazdy_id_wyjazdu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wyjazdy_id_wyjazdu_seq OWNER TO postgres;

--
-- Name: wyjazdy_id_wyjazdu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wyjazdy_id_wyjazdu_seq OWNED BY public.wyjazdy.id_wyjazdu;


--
-- Name: zespoly_id_zespolu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zespoly_id_zespolu_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zespoly_id_zespolu_seq OWNER TO postgres;

--
-- Name: zespoly_id_zespolu_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zespoly_id_zespolu_seq OWNED BY public.zespoly.id_zespolu;


--
-- Name: zmiany; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zmiany (
    id_zmiany integer NOT NULL,
    data_zmiany date NOT NULL,
    godzina_start time without time zone NOT NULL,
    godzina_koniec time without time zone NOT NULL,
    typ_zmiany character varying(20) NOT NULL,
    CONSTRAINT zmiany_typ_zmiany_check CHECK (((typ_zmiany)::text = ANY ((ARRAY['dzienna'::character varying, 'nocna'::character varying])::text[])))
);


ALTER TABLE public.zmiany OWNER TO postgres;

--
-- Name: zmiany_id_zmiany_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zmiany_id_zmiany_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.zmiany_id_zmiany_seq OWNER TO postgres;

--
-- Name: zmiany_id_zmiany_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zmiany_id_zmiany_seq OWNED BY public.zmiany.id_zmiany;


--
-- Name: dyspozytorzy id_dyspozytora; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy ALTER COLUMN id_dyspozytora SET DEFAULT nextval('public.dyspozytorzy_id_dyspozytora_seq'::regclass);


--
-- Name: dyspozytorzy_zmiany id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy_zmiany ALTER COLUMN id SET DEFAULT nextval('public.dyspozytorzy_zmiany_id_seq'::regclass);


--
-- Name: karetki id_karetki; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.karetki ALTER COLUMN id_karetki SET DEFAULT nextval('public.karetki_id_karetki_seq'::regclass);


--
-- Name: katalog_swiadczen id_swiadczenia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.katalog_swiadczen ALTER COLUMN id_swiadczenia SET DEFAULT nextval('public.katalog_swiadczen_id_swiadczenia_seq'::regclass);


--
-- Name: log_wezwan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_wezwan ALTER COLUMN id SET DEFAULT nextval('public.log_wezwan_id_seq'::regclass);


--
-- Name: pacjenci id_pacjenta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacjenci ALTER COLUMN id_pacjenta SET DEFAULT nextval('public.pacjenci_id_pacjenta_seq'::regclass);


--
-- Name: pracownicy id_pracownika; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownicy ALTER COLUMN id_pracownika SET DEFAULT nextval('public.pracownicy_id_pracownika_seq'::regclass);


--
-- Name: sklad_zespolu id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sklad_zespolu ALTER COLUMN id SET DEFAULT nextval('public.sklad_zespolu_id_seq'::regclass);


--
-- Name: udzielona_pomoc id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.udzielona_pomoc ALTER COLUMN id SET DEFAULT nextval('public.udzielona_pomoc_id_seq'::regclass);


--
-- Name: wezwania id_wezwania; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wezwania ALTER COLUMN id_wezwania SET DEFAULT nextval('public.wezwania_id_wezwania_seq'::regclass);


--
-- Name: wyjazd_pacjent id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazd_pacjent ALTER COLUMN id SET DEFAULT nextval('public.wyjazd_pacjent_id_seq'::regclass);


--
-- Name: wyjazdy id_wyjazdu; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazdy ALTER COLUMN id_wyjazdu SET DEFAULT nextval('public.wyjazdy_id_wyjazdu_seq'::regclass);


--
-- Name: zespoly id_zespolu; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zespoly ALTER COLUMN id_zespolu SET DEFAULT nextval('public.zespoly_id_zespolu_seq'::regclass);


--
-- Name: zmiany id_zmiany; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zmiany ALTER COLUMN id_zmiany SET DEFAULT nextval('public.zmiany_id_zmiany_seq'::regclass);


--
-- Data for Name: dyspozytorzy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dyspozytorzy (id_dyspozytora, imie, nazwisko, telefon, email) FROM stdin;
1	Anna	Kowalska	500100001	a.kowalska@pogotowie.pl
2	Marek	Nowak	500100002	m.nowak@pogotowie.pl
3	Joanna	Wiśniewska	500100003	j.wisniewska@pogotowie.pl
4	Tomasz	Wójcik	500100004	t.wojcik@pogotowie.pl
5	Katarzyna	Kowalczyk	500100005	k.kowalczyk@pogotowie.pl
\.


--
-- Data for Name: dyspozytorzy_zmiany; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dyspozytorzy_zmiany (id, id_dyspozytora, id_zmiany) FROM stdin;
1	1	1
2	2	2
3	3	3
4	4	4
5	5	5
\.


--
-- Data for Name: karetki; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.karetki (id_karetki, nr_rejestracyjny, typ_karetki, rok_produkcji, status) FROM stdin;
1	LDZ 1A001	P	2019	DOSTEPNA
2	LDZ 1A002	P	2020	DOSTEPNA
3	LDZ 1B003	S	2021	DOSTEPNA
4	LDZ 1B004	S	2022	DOSTEPNA
5	LDZ 1C005	R	2021	DOSTEPNA
6	LDZ 1C006	R	2023	DOSTEPNA
7	LDZ 1A007	P	2018	W_SERWISIE
8	LDZ 1B008	S	2020	DOSTEPNA
\.


--
-- Data for Name: katalog_swiadczen; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.katalog_swiadczen (id_swiadczenia, kod_procedury, nazwa, kategoria, opis) FROM stdin;
1	RKO01	Resuscytacja krążeniowo-oddechowa (RKO)	resuscytacja	Uciskanie klatki + wentylacja
2	INT01	Intubacja dotchawicza	wentylacja	Zabezpieczenie drożności dróg oddechowych
3	EKG01	EKG 12-odprowadzeniowe	diagnostyka	Rejestracja elektrokardiogramu
4	CIS01	Pomiar ciśnienia tętniczego	diagnostyka	Ciśnienie metodą osłuchową lub NIBP
5	OXY01	Pulsoksymetria	diagnostyka	Pomiar saturacji krwi tlenem
6	TLE01	Tlenoterapia bierna	wentylacja	Podanie tlenu przez maskę/wąsy
7	DEF01	Defibrylacja elektryczna	resuscytacja	Wyładowanie elektryczne przy VF/VT
8	GUK01	Pomiar glikemii	diagnostyka	Glukometr nakłuciowy
9	WKL01	Wkłucie obwodowe (kaniula i.v.)	dostęp_naczyniowy	Obwodowy dostęp dożylny
10	PLY01	Podanie płynów infuzyjnych	farmakoterapia	NaCl 0.9% lub Ringer i.v.
11	ADR01	Podanie adrenaliny i.v.	farmakoterapia	Epinefryna 1 mg/ml i.v.
12	GLU01	Podanie glukozy 40% i.v.	farmakoterapia	Leczenie hipoglikemii
13	NIT01	Podanie nitrogliceryny s.l.	farmakoterapia	Spray lub tabletka podjęzykowa
14	MOR01	Podanie morfiny i.v.	farmakoterapia	Analgezja opioidowa
15	IMP01	Unieruchomienie złamania (szyna/deska)	ortopedia	Stabilizacja złamania lub skręcenia
16	OPA01	Opatrunek rany	chirurgia	Jałowy opatrunek uciskowy
17	NEB01	Nebulizacja leku rozszerzającego oskrzela	wentylacja	Salbutamol lub bromek ipratropium
18	USG01	USG FAST (uraz)	diagnostyka	Szybka ocena jamy brzusznej i klatki
19	GCS01	Ocena stanu świadomości (GCS)	diagnostyka	Skala Glasgow Coma Scale
20	ZAB01	Zabezpieczenie kręgosłupa (kołnierz + deska)	ortopedia	Immobilizacja kręgosłupa szyjnego
\.


--
-- Data for Name: log_wezwan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_wezwan (id, id_wezwania, stary_status, nowy_status, zmieniono_o, uzytkownik) FROM stdin;
\.


--
-- Data for Name: pacjenci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pacjenci (id_pacjenta, imie, nazwisko, pesel, data_urodzenia, plec, nr_telefonu, adres) FROM stdin;
1	Jan	Zielony	59010198765	1959-01-01	M	600200001	ul. Piotrkowska 120, Łódź
2	Maria	Kwiatkowska	74060678901	1974-06-06	K	600200002	ul. Kilińskiego 45, Łódź
3	Helena	Stępień	52080545678	1952-08-05	K	600200003	ul. Legionów 78, Łódź
4	Tomasz	Borowski	98112234567	1998-11-22	M	600200004	ul. Zgierska 34, Łódź
5	Zofia	Michalak	65030367890	1965-03-03	K	600200005	ul. Retkińska 56, Łódź
6	Aleksander	Pawlak	01010101234	2001-01-01	M	600200006	ul. Rzgowska 90, Łódź
7	Renata	Grabowska	83071189012	1983-07-11	K	600200007	ul. Dąbrowskiego 77, Łódź
8	Stanisław	Woźniak	55020290123	1955-02-02	M	600200008	ul. Narutowicza 5, Łódź
9	Elżbieta	Kaczmarek	70050556789	1970-05-05	K	600200009	ul. Północna 22, Łódź
10	Konrad	Zawadzki	90120312345	1990-12-03	M	600200010	ul. Tuszyńska 61, Łódź
\.


--
-- Data for Name: pracownicy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pracownicy (id_pracownika, imie, nazwisko, pesel, stanowisko, nr_uprawnien) FROM stdin;
1	Piotr	Adamski	85010112345	ratownik_medyczny	RM/001/2015
2	Monika	Baran	90020223456	ratownik_medyczny	RM/002/2016
3	Krzysztof	Czajka	78030334567	lekarz	LEK/001/2010
4	Ewa	Dąbrowska	92040445678	ratownik_medyczny	RM/003/2018
5	Rafał	Ewald	88050556789	ratownik_medyczny	RM/004/2017
6	Sylwia	Frankowska	95060667890	ratownik_medyczny	RM/005/2019
7	Andrzej	Górski	82070778901	lekarz	LEK/002/2012
8	Beata	Hajduk	91080889012	ratownik_medyczny	RM/006/2018
9	Łukasz	Iwan	87090990123	ratownik_medyczny	RM/007/2016
10	Natalia	Jabłońska	93100101234	ratownik_medyczny	RM/008/2020
11	Michał	Kasprzak	80111112345	lekarz	LEK/003/2008
12	Paulina	Lewandowska	96120223456	ratownik_medyczny	RM/009/2021
13	Grzegorz	Malinowski	75010134567	kierowca	KIR/001/2005
14	Dorota	Nowicka	89020245678	kierowca	KIR/002/2010
15	Bartosz	Olszewski	94030356789	kierowca	KIR/003/2019
\.


--
-- Data for Name: sklad_zespolu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sklad_zespolu (id, id_zespolu, id_pracownika, rola_w_zespole) FROM stdin;
1	1	13	kierowca
2	1	1	ratownik_medyczny
3	2	14	kierowca
4	2	2	ratownik_medyczny
5	3	15	kierowca
6	3	4	ratownik_medyczny
7	3	5	ratownik_medyczny
8	4	13	kierowca
9	4	6	ratownik_medyczny
10	5	14	kierowca
11	5	3	lekarz
12	5	8	ratownik_medyczny
13	6	15	kierowca
14	6	7	lekarz
15	6	9	ratownik_medyczny
\.


--
-- Data for Name: udzielona_pomoc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.udzielona_pomoc (id, id_wyjazdu, id_pacjenta, id_swiadczenia, godzina_wykonania, wynik, uwagi) FROM stdin;
1	1	1	3	2025-01-10 08:37:00	wykonano	STEMI – uniesienie ST w II, III, aVF
2	1	1	9	2025-01-10 08:39:00	wykonano	Kaniula 18G lewa ręka
3	1	1	10	2025-01-10 08:40:00	wykonano	NaCl 500ml
4	1	1	13	2025-01-10 08:41:00	wykonano	NTG s.l. 0.4mg
5	2	2	19	2025-01-10 21:57:00	wykonano	GCS 12
6	2	2	4	2025-01-10 21:58:00	wykonano	RR 100/70
7	2	2	20	2025-01-10 22:00:00	wykonano	Kołnierz Philadelphia
8	3	3	19	2025-01-11 09:24:00	wykonano	GCS 9, asymetria twarzy
9	3	3	5	2025-01-11 09:25:00	wykonano	SpO2 91%
10	3	3	6	2025-01-11 09:26:00	wykonano	O2 8l/min maska
11	3	3	9	2025-01-11 09:28:00	wykonano	Kaniula 18G
12	5	5	19	2025-01-11 22:32:00	wykonano	GCS 8 po napadzie
13	5	5	6	2025-01-11 22:33:00	wykonano	Tlenoterapia bierna
14	6	6	1	2025-01-12 08:16:00	wykonano	RKO u niemowlęcia – 30:2
15	6	6	7	2025-01-12 08:18:00	wykonano	Defibrylacja 4J/kg
16	9	8	18	2025-01-13 08:54:00	wykonano	FAST – płyn wolny w jamie brzusznej
17	9	8	20	2025-01-13 08:55:00	wykonano	Pełna immobilizacja
18	9	8	9	2025-01-13 08:57:00	wykonano	Dwa wkłucia obwodowe
19	9	8	10	2025-01-13 08:58:00	wykonano	Przetoczono 1000ml Ringera
20	14	10	1	2025-01-15 08:24:00	wykonano	RKO wdrożone natychmiast
21	14	10	2	2025-01-15 08:26:00	wykonano	Intubacja dotchawicza rozmiar 7.5
22	14	10	11	2025-01-15 08:28:00	wykonano	Adrenalina 1mg i.v. × 3
23	15	9	8	2025-01-15 10:44:00	wykonano	Glukoza 42 mg/dl
24	15	9	12	2025-01-15 10:46:00	wykonano	Glukoza 40% 40ml i.v.
\.


--
-- Data for Name: wezwania; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wezwania (id_wezwania, id_dyspozytora, data_zgloszenia, godzina_zgloszenia, adres, miasto, priorytet, opis_zdarzenia, status) FROM stdin;
1	1	2025-01-10	08:15:00	ul. Piotrkowska 120	Łódź	P1	Zawał serca, mężczyzna 65l.	ZAKONCZONE
2	2	2025-01-10	21:30:00	ul. Kilińskiego 45	Łódź	P2	Wypadek drogowy, 2 osoby.	ZAKONCZONE
3	3	2025-01-11	09:00:00	ul. Legionów 78	Łódź	P1	Udar mózgu, kobieta 72l.	ZAKONCZONE
4	4	2025-01-11	14:45:00	ul. Zgierska 34	Łódź	P3	Złamanie nogi, sport.	ZAKONCZONE
5	1	2025-01-11	22:10:00	ul. Retkińska 56	Łódź	P2	Napad padaczkowy.	ZAKONCZONE
6	2	2025-01-12	07:55:00	ul. Rzgowska 90	Łódź	P1	Niemowlę – bezdech.	ZAKONCZONE
7	3	2025-01-12	11:20:00	ul. Widzewska 12	Łódź	P3	Stłuczenie głowy, upadek.	ZAKONCZONE
8	5	2025-01-12	16:00:00	ul. Dąbrowskiego 77	Łódź	P2	Ból w klatce piersiowej.	ZAKONCZONE
9	1	2025-01-13	08:30:00	ul. Narutowicza 5	Łódź	P1	Wypadek motocyklowy.	ZAKONCZONE
10	2	2025-01-13	13:15:00	ul. Północna 22	Łódź	P2	Zatrucie lekami.	ZAKONCZONE
11	4	2025-01-13	18:00:00	ul. Łagiewnicka 44	Łódź	P3	Skręcenie kostki.	ZAKONCZONE
12	3	2025-01-14	09:45:00	ul. Srebrzyńska 18	Łódź	P1	Ciężki uraz wielonarządowy.	W_REALIZACJI
13	5	2025-01-14	11:30:00	ul. Aleksandrowska 3	Łódź	P2	Astma – atak.	ZAKONCZONE
14	1	2025-01-14	15:00:00	ul. Pomorska 88	Łódź	P3	Krwotok z nosa, pacjent 80l.	ZAKONCZONE
15	2	2025-01-15	08:00:00	ul. Tuszyńska 61	Łódź	P1	Resuscytacja, ofiara utonięcia.	ZAKONCZONE
16	4	2025-01-15	10:20:00	ul. Przybyszewskiego 3	Łódź	P2	Hipoglikemia, cukrzyk.	ZAKONCZONE
17	5	2025-01-15	14:10:00	ul. Wólczańska 200	Łódź	P3	Ból brzucha, dziecko 8l.	ZAKONCZONE
18	3	2025-01-16	07:40:00	ul. Rokicińska 45	Łódź	P1	Pożar – poparzenia III st.	ZAKONCZONE
19	1	2025-01-16	12:00:00	ul. Górna 99	Łódź	P2	Omdlenie w miejscu pracy.	ZAKONCZONE
20	2	2025-01-16	17:30:00	ul. Nowe Sady 8	Łódź	P1	Uraz głowy – wypadek.	NOWE
\.


--
-- Data for Name: wyjazd_pacjent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wyjazd_pacjent (id, id_wyjazdu, id_pacjenta, stan_przy_przyjeciu, stan_przy_przekazaniu, miejsce_przekazania) FROM stdin;
26	1	1	krytyczny	stabilny	USK im. WAM Łódź
27	2	2	ciężki	stabilny	SOR Biegańskiego
28	2	4	umiarkowany	dobry	SOR Biegańskiego
29	3	3	krytyczny	stabilny	USK im. WAM Łódź
30	4	4	lekki	dobry	SOR Kopernika
31	5	5	umiarkowany	stabilny	SOR Biegańskiego
32	6	6	krytyczny	krytyczny	USK im. WAM Łódź
33	8	7	umiarkowany	stabilny	SOR Biegańskiego
34	9	8	krytyczny	ciężki	USK im. WAM Łódź
35	10	9	ciężki	stabilny	SOR Kopernika
36	14	10	krytyczny	stabilny	USK im. WAM Łódź
37	15	9	ciężki	dobry	SOR Kopernika
\.


--
-- Data for Name: wyjazdy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wyjazdy (id_wyjazdu, id_wezwania, id_karetki, id_zespolu, czas_wyjazdu, czas_przybycia, czas_powrotu, miejsce_docelowe, uwagi) FROM stdin;
1	1	5	5	2025-01-10 08:20:00	2025-01-10 08:35:00	2025-01-10 09:45:00	USK im. WAM Łódź	Przekazano na OIOM
2	2	3	3	2025-01-10 21:38:00	2025-01-10 21:55:00	2025-01-10 23:10:00	SOR Szpital Biegańskiego	Dwóch poszkodowanych
3	3	6	6	2025-01-11 09:08:00	2025-01-11 09:22:00	2025-01-11 10:40:00	USK im. WAM Łódź	Udar niedokrwienny
4	4	1	1	2025-01-11 14:52:00	2025-01-11 15:05:00	2025-01-11 16:00:00	SOR Szpital Kopernika	\N
5	5	2	2	2025-01-11 22:18:00	2025-01-11 22:30:00	2025-01-11 23:20:00	SOR Szpital Biegańskiego	\N
6	6	5	5	2025-01-12 08:02:00	2025-01-12 08:15:00	2025-01-12 09:00:00	USK im. WAM Łódź	Niemowlę, krytyczny stan
7	7	4	4	2025-01-12 11:28:00	2025-01-12 11:40:00	2025-01-12 12:30:00	SOR Szpital Kopernika	\N
8	8	3	3	2025-01-12 16:08:00	2025-01-12 16:25:00	2025-01-12 17:40:00	SOR Szpital Biegańskiego	\N
9	9	6	6	2025-01-13 08:38:00	2025-01-13 08:52:00	2025-01-13 10:15:00	USK im. WAM Łódź	Politrauma
10	10	2	2	2025-01-13 13:22:00	2025-01-13 13:38:00	2025-01-13 14:50:00	SOR Szpital Kopernika	Płukanie żołądka w SOR
11	11	1	1	2025-01-13 18:08:00	2025-01-13 18:20:00	2025-01-13 19:00:00	Miejsce zdarzenia	Brak transportu – odmowa
12	13	4	4	2025-01-14 11:38:00	2025-01-14 11:50:00	2025-01-14 12:45:00	SOR Szpital Biegańskiego	\N
13	14	1	1	2025-01-14 15:08:00	2025-01-14 15:20:00	2025-01-14 16:00:00	Miejsce zdarzenia	Zatamowano krwotok
14	15	6	5	2025-01-15 08:08:00	2025-01-15 08:22:00	2025-01-15 09:30:00	USK im. WAM Łódź	RKO wdrożone w karetce
15	16	2	2	2025-01-15 10:28:00	2025-01-15 10:42:00	2025-01-15 11:30:00	SOR Szpital Kopernika	Podano glukozę i.v.
\.


--
-- Data for Name: zespoly; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zespoly (id_zespolu, nazwa_zespolu, typ_zespolu) FROM stdin;
1	Alfa-1	podstawowy
2	Alfa-2	podstawowy
3	Beta-1	specjalistyczny
4	Beta-2	specjalistyczny
5	Gamma-1	reanimacyjny
6	Gamma-2	reanimacyjny
\.


--
-- Data for Name: zmiany; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zmiany (id_zmiany, data_zmiany, godzina_start, godzina_koniec, typ_zmiany) FROM stdin;
1	2025-01-10	07:00:00	19:00:00	dzienna
2	2025-01-10	19:00:00	07:00:00	nocna
3	2025-01-11	07:00:00	19:00:00	dzienna
4	2025-01-11	19:00:00	07:00:00	nocna
5	2025-01-12	07:00:00	19:00:00	dzienna
\.


--
-- Name: dyspozytorzy_id_dyspozytora_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dyspozytorzy_id_dyspozytora_seq', 5, true);


--
-- Name: dyspozytorzy_zmiany_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dyspozytorzy_zmiany_id_seq', 5, true);


--
-- Name: karetki_id_karetki_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.karetki_id_karetki_seq', 8, true);


--
-- Name: katalog_swiadczen_id_swiadczenia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.katalog_swiadczen_id_swiadczenia_seq', 20, true);


--
-- Name: log_wezwan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_wezwan_id_seq', 1, true);


--
-- Name: pacjenci_id_pacjenta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pacjenci_id_pacjenta_seq', 10, true);


--
-- Name: pracownicy_id_pracownika_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pracownicy_id_pracownika_seq', 15, true);


--
-- Name: sklad_zespolu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sklad_zespolu_id_seq', 15, true);


--
-- Name: udzielona_pomoc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.udzielona_pomoc_id_seq', 24, true);


--
-- Name: wezwania_id_wezwania_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wezwania_id_wezwania_seq', 21, true);


--
-- Name: wyjazd_pacjent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wyjazd_pacjent_id_seq', 37, true);


--
-- Name: wyjazdy_id_wyjazdu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.wyjazdy_id_wyjazdu_seq', 20, true);


--
-- Name: zespoly_id_zespolu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zespoly_id_zespolu_seq', 7, true);


--
-- Name: zmiany_id_zmiany_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zmiany_id_zmiany_seq', 5, true);


--
-- Name: dyspozytorzy dyspozytorzy_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy
    ADD CONSTRAINT dyspozytorzy_email_key UNIQUE (email);


--
-- Name: dyspozytorzy dyspozytorzy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy
    ADD CONSTRAINT dyspozytorzy_pkey PRIMARY KEY (id_dyspozytora);


--
-- Name: dyspozytorzy_zmiany dyspozytorzy_zmiany_id_dyspozytora_id_zmiany_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy_zmiany
    ADD CONSTRAINT dyspozytorzy_zmiany_id_dyspozytora_id_zmiany_key UNIQUE (id_dyspozytora, id_zmiany);


--
-- Name: dyspozytorzy_zmiany dyspozytorzy_zmiany_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy_zmiany
    ADD CONSTRAINT dyspozytorzy_zmiany_pkey PRIMARY KEY (id);


--
-- Name: karetki karetki_nr_rejestracyjny_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.karetki
    ADD CONSTRAINT karetki_nr_rejestracyjny_key UNIQUE (nr_rejestracyjny);


--
-- Name: karetki karetki_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.karetki
    ADD CONSTRAINT karetki_pkey PRIMARY KEY (id_karetki);


--
-- Name: katalog_swiadczen katalog_swiadczen_kod_procedury_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.katalog_swiadczen
    ADD CONSTRAINT katalog_swiadczen_kod_procedury_key UNIQUE (kod_procedury);


--
-- Name: katalog_swiadczen katalog_swiadczen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.katalog_swiadczen
    ADD CONSTRAINT katalog_swiadczen_pkey PRIMARY KEY (id_swiadczenia);


--
-- Name: log_wezwan log_wezwan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_wezwan
    ADD CONSTRAINT log_wezwan_pkey PRIMARY KEY (id);


--
-- Name: pacjenci pacjenci_pesel_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacjenci
    ADD CONSTRAINT pacjenci_pesel_key UNIQUE (pesel);


--
-- Name: pacjenci pacjenci_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pacjenci
    ADD CONSTRAINT pacjenci_pkey PRIMARY KEY (id_pacjenta);


--
-- Name: pracownicy pracownicy_nr_uprawnien_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownicy
    ADD CONSTRAINT pracownicy_nr_uprawnien_key UNIQUE (nr_uprawnien);


--
-- Name: pracownicy pracownicy_pesel_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownicy
    ADD CONSTRAINT pracownicy_pesel_key UNIQUE (pesel);


--
-- Name: pracownicy pracownicy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pracownicy
    ADD CONSTRAINT pracownicy_pkey PRIMARY KEY (id_pracownika);


--
-- Name: sklad_zespolu sklad_zespolu_id_zespolu_id_pracownika_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sklad_zespolu
    ADD CONSTRAINT sklad_zespolu_id_zespolu_id_pracownika_key UNIQUE (id_zespolu, id_pracownika);


--
-- Name: sklad_zespolu sklad_zespolu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sklad_zespolu
    ADD CONSTRAINT sklad_zespolu_pkey PRIMARY KEY (id);


--
-- Name: udzielona_pomoc udzielona_pomoc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.udzielona_pomoc
    ADD CONSTRAINT udzielona_pomoc_pkey PRIMARY KEY (id);


--
-- Name: wezwania wezwania_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wezwania
    ADD CONSTRAINT wezwania_pkey PRIMARY KEY (id_wezwania);


--
-- Name: wyjazd_pacjent wyjazd_pacjent_id_wyjazdu_id_pacjenta_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazd_pacjent
    ADD CONSTRAINT wyjazd_pacjent_id_wyjazdu_id_pacjenta_key UNIQUE (id_wyjazdu, id_pacjenta);


--
-- Name: wyjazd_pacjent wyjazd_pacjent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazd_pacjent
    ADD CONSTRAINT wyjazd_pacjent_pkey PRIMARY KEY (id);


--
-- Name: wyjazdy wyjazdy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazdy
    ADD CONSTRAINT wyjazdy_pkey PRIMARY KEY (id_wyjazdu);


--
-- Name: zespoly zespoly_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zespoly
    ADD CONSTRAINT zespoly_pkey PRIMARY KEY (id_zespolu);


--
-- Name: zmiany zmiany_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zmiany
    ADD CONSTRAINT zmiany_pkey PRIMARY KEY (id_zmiany);


--
-- Name: idx_dyz_dyspozytor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dyz_dyspozytor ON public.dyspozytorzy_zmiany USING btree (id_dyspozytora);


--
-- Name: idx_dyz_zmiana; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_dyz_zmiana ON public.dyspozytorzy_zmiany USING btree (id_zmiany);


--
-- Name: idx_sklad_zespolu_pracownik; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sklad_zespolu_pracownik ON public.sklad_zespolu USING btree (id_pracownika);


--
-- Name: idx_sklad_zespolu_zespol; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sklad_zespolu_zespol ON public.sklad_zespolu USING btree (id_zespolu);


--
-- Name: idx_up_pacjent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_up_pacjent ON public.udzielona_pomoc USING btree (id_pacjenta);


--
-- Name: idx_up_swiadczenie; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_up_swiadczenie ON public.udzielona_pomoc USING btree (id_swiadczenia);


--
-- Name: idx_up_wyjazd; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_up_wyjazd ON public.udzielona_pomoc USING btree (id_wyjazdu);


--
-- Name: idx_wezwania_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wezwania_data ON public.wezwania USING btree (data_zgloszenia);


--
-- Name: idx_wezwania_dyspozytor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wezwania_dyspozytor ON public.wezwania USING btree (id_dyspozytora);


--
-- Name: idx_wezwania_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wezwania_status ON public.wezwania USING btree (status);


--
-- Name: idx_wp_pacjent; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wp_pacjent ON public.wyjazd_pacjent USING btree (id_pacjenta);


--
-- Name: idx_wp_wyjazd; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wp_wyjazd ON public.wyjazd_pacjent USING btree (id_wyjazdu);


--
-- Name: idx_wyjazdy_karetka; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wyjazdy_karetka ON public.wyjazdy USING btree (id_karetki);


--
-- Name: idx_wyjazdy_wezwanie; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wyjazdy_wezwanie ON public.wyjazdy USING btree (id_wezwania);


--
-- Name: idx_wyjazdy_zespol; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_wyjazdy_zespol ON public.wyjazdy USING btree (id_zespolu);


--
-- Name: wezwania trg_log_statusu_wezwania; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_log_statusu_wezwania AFTER UPDATE ON public.wezwania FOR EACH ROW EXECUTE FUNCTION public.fn_loguj_zmiane_statusu();


--
-- Name: wyjazdy trg_status_karetki; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_status_karetki AFTER INSERT OR UPDATE ON public.wyjazdy FOR EACH ROW EXECUTE FUNCTION public.fn_aktualizuj_status_karetki();


--
-- Name: wyjazdy trg_walidacja_zespolu; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_walidacja_zespolu BEFORE INSERT ON public.wyjazdy FOR EACH ROW EXECUTE FUNCTION public.fn_waliduj_sklad_zespolu();


--
-- Name: dyspozytorzy_zmiany dyspozytorzy_zmiany_id_dyspozytora_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy_zmiany
    ADD CONSTRAINT dyspozytorzy_zmiany_id_dyspozytora_fkey FOREIGN KEY (id_dyspozytora) REFERENCES public.dyspozytorzy(id_dyspozytora);


--
-- Name: dyspozytorzy_zmiany dyspozytorzy_zmiany_id_zmiany_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dyspozytorzy_zmiany
    ADD CONSTRAINT dyspozytorzy_zmiany_id_zmiany_fkey FOREIGN KEY (id_zmiany) REFERENCES public.zmiany(id_zmiany);


--
-- Name: sklad_zespolu sklad_zespolu_id_pracownika_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sklad_zespolu
    ADD CONSTRAINT sklad_zespolu_id_pracownika_fkey FOREIGN KEY (id_pracownika) REFERENCES public.pracownicy(id_pracownika);


--
-- Name: sklad_zespolu sklad_zespolu_id_zespolu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sklad_zespolu
    ADD CONSTRAINT sklad_zespolu_id_zespolu_fkey FOREIGN KEY (id_zespolu) REFERENCES public.zespoly(id_zespolu);


--
-- Name: udzielona_pomoc udzielona_pomoc_id_pacjenta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.udzielona_pomoc
    ADD CONSTRAINT udzielona_pomoc_id_pacjenta_fkey FOREIGN KEY (id_pacjenta) REFERENCES public.pacjenci(id_pacjenta);


--
-- Name: udzielona_pomoc udzielona_pomoc_id_swiadczenia_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.udzielona_pomoc
    ADD CONSTRAINT udzielona_pomoc_id_swiadczenia_fkey FOREIGN KEY (id_swiadczenia) REFERENCES public.katalog_swiadczen(id_swiadczenia);


--
-- Name: udzielona_pomoc udzielona_pomoc_id_wyjazdu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.udzielona_pomoc
    ADD CONSTRAINT udzielona_pomoc_id_wyjazdu_fkey FOREIGN KEY (id_wyjazdu) REFERENCES public.wyjazdy(id_wyjazdu);


--
-- Name: wezwania wezwania_id_dyspozytora_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wezwania
    ADD CONSTRAINT wezwania_id_dyspozytora_fkey FOREIGN KEY (id_dyspozytora) REFERENCES public.dyspozytorzy(id_dyspozytora);


--
-- Name: wyjazd_pacjent wyjazd_pacjent_id_pacjenta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazd_pacjent
    ADD CONSTRAINT wyjazd_pacjent_id_pacjenta_fkey FOREIGN KEY (id_pacjenta) REFERENCES public.pacjenci(id_pacjenta);


--
-- Name: wyjazd_pacjent wyjazd_pacjent_id_wyjazdu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazd_pacjent
    ADD CONSTRAINT wyjazd_pacjent_id_wyjazdu_fkey FOREIGN KEY (id_wyjazdu) REFERENCES public.wyjazdy(id_wyjazdu);


--
-- Name: wyjazdy wyjazdy_id_karetki_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazdy
    ADD CONSTRAINT wyjazdy_id_karetki_fkey FOREIGN KEY (id_karetki) REFERENCES public.karetki(id_karetki);


--
-- Name: wyjazdy wyjazdy_id_wezwania_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazdy
    ADD CONSTRAINT wyjazdy_id_wezwania_fkey FOREIGN KEY (id_wezwania) REFERENCES public.wezwania(id_wezwania);


--
-- Name: wyjazdy wyjazdy_id_zespolu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wyjazdy
    ADD CONSTRAINT wyjazdy_id_zespolu_fkey FOREIGN KEY (id_zespolu) REFERENCES public.zespoly(id_zespolu);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO dyspozytor;
GRANT USAGE ON SCHEMA public TO ratownik;


--
-- Name: TABLE dyspozytorzy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.dyspozytorzy TO dyspozytor;
GRANT SELECT ON TABLE public.dyspozytorzy TO ratownik;


--
-- Name: TABLE dyspozytorzy_zmiany; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.dyspozytorzy_zmiany TO dyspozytor;
GRANT SELECT ON TABLE public.dyspozytorzy_zmiany TO ratownik;


--
-- Name: TABLE karetki; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.karetki TO dyspozytor;
GRANT SELECT ON TABLE public.karetki TO ratownik;


--
-- Name: TABLE katalog_swiadczen; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.katalog_swiadczen TO dyspozytor;
GRANT SELECT ON TABLE public.katalog_swiadczen TO ratownik;


--
-- Name: TABLE log_wezwan; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.log_wezwan TO dyspozytor;
GRANT SELECT ON TABLE public.log_wezwan TO ratownik;


--
-- Name: TABLE pacjenci; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.pacjenci TO dyspozytor;
GRANT SELECT,INSERT,UPDATE ON TABLE public.pacjenci TO ratownik;


--
-- Name: SEQUENCE pacjenci_id_pacjenta_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.pacjenci_id_pacjenta_seq TO ratownik;


--
-- Name: TABLE pracownicy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.pracownicy TO dyspozytor;
GRANT SELECT ON TABLE public.pracownicy TO ratownik;


--
-- Name: TABLE sklad_zespolu; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.sklad_zespolu TO dyspozytor;
GRANT SELECT ON TABLE public.sklad_zespolu TO ratownik;


--
-- Name: TABLE udzielona_pomoc; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.udzielona_pomoc TO dyspozytor;
GRANT SELECT,INSERT,UPDATE ON TABLE public.udzielona_pomoc TO ratownik;


--
-- Name: SEQUENCE udzielona_pomoc_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.udzielona_pomoc_id_seq TO ratownik;


--
-- Name: TABLE wezwania; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.wezwania TO dyspozytor;
GRANT SELECT ON TABLE public.wezwania TO ratownik;


--
-- Name: COLUMN wezwania.status; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(status) ON TABLE public.wezwania TO dyspozytor;


--
-- Name: TABLE wyjazd_pacjent; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.wyjazd_pacjent TO dyspozytor;
GRANT SELECT,INSERT,UPDATE ON TABLE public.wyjazd_pacjent TO ratownik;


--
-- Name: TABLE wyjazdy; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.wyjazdy TO dyspozytor;
GRANT SELECT,INSERT,UPDATE ON TABLE public.wyjazdy TO ratownik;


--
-- Name: COLUMN wyjazdy.id_karetki; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(id_karetki) ON TABLE public.wyjazdy TO dyspozytor;


--
-- Name: COLUMN wyjazdy.id_zespolu; Type: ACL; Schema: public; Owner: postgres
--

GRANT UPDATE(id_zespolu) ON TABLE public.wyjazdy TO dyspozytor;


--
-- Name: TABLE v_historia_pacjenta; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.v_historia_pacjenta TO dyspozytor;
GRANT SELECT ON TABLE public.v_historia_pacjenta TO ratownik;


--
-- Name: TABLE v_obciazenie_dyspozytorni; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.v_obciazenie_dyspozytorni TO dyspozytor;
GRANT SELECT ON TABLE public.v_obciazenie_dyspozytorni TO ratownik;


--
-- Name: TABLE zespoly; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.zespoly TO dyspozytor;
GRANT SELECT ON TABLE public.zespoly TO ratownik;


--
-- Name: TABLE v_szczegoly_wyjazdu; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.v_szczegoly_wyjazdu TO dyspozytor;
GRANT SELECT ON TABLE public.v_szczegoly_wyjazdu TO ratownik;


--
-- Name: SEQUENCE wezwania_id_wezwania_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.wezwania_id_wezwania_seq TO dyspozytor;


--
-- Name: SEQUENCE wyjazd_pacjent_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.wyjazd_pacjent_id_seq TO ratownik;


--
-- Name: SEQUENCE wyjazdy_id_wyjazdu_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT USAGE ON SEQUENCE public.wyjazdy_id_wyjazdu_seq TO dyspozytor;
GRANT USAGE ON SEQUENCE public.wyjazdy_id_wyjazdu_seq TO ratownik;


--
-- Name: TABLE zmiany; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.zmiany TO dyspozytor;
GRANT SELECT ON TABLE public.zmiany TO ratownik;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO dyspozytor;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO ratownik;


--
-- PostgreSQL database dump complete
--

\unrestrict ttofGV5du579NwuKTpuSeiyNTIQyGjDGJU6uJ6hKpMhcb2wwrfL7Wurdpq7XeTl

