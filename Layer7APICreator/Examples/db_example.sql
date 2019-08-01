-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Erstellungszeit: 01. Aug 2019 um 10:09
-- Server-Version: 8.0.16
-- PHP-Version: 7.2.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `andreas`
--
CREATE DATABASE IF NOT EXISTS `andreas` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `andreas`;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `Adresse1`
--

CREATE TABLE `Adresse1` (
  `ID` int(11) NOT NULL,
  `Vorname` varchar(50) NOT NULL,
  `Nachname` varchar(50) NOT NULL,
  `Strasse` varchar(50) NOT NULL,
  `Ort` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Daten für Tabelle `Adresse1`
--

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `MQTT_Audit`
--

CREATE TABLE `MQTT_Audit` (
  `ID` int(11) NOT NULL,
  `date` datetime NOT NULL,
  `message` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Daten für Tabelle `MQTT_Audit`
--

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `Adresse1`
--
ALTER TABLE `Adresse1`
  ADD PRIMARY KEY (`Vorname`,`Nachname`),
  ADD KEY `ID` (`ID`);

--
-- Indizes für die Tabelle `MQTT_Audit`
--
ALTER TABLE `MQTT_Audit`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT für exportierte Tabellen
--

--
-- AUTO_INCREMENT für Tabelle `Adresse1`
--
ALTER TABLE `Adresse1`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT für Tabelle `MQTT_Audit`
--
ALTER TABLE `MQTT_Audit`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
