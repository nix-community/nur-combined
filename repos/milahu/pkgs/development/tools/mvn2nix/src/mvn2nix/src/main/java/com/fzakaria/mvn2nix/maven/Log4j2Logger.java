package com.fzakaria.mvn2nix.maven;

import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.core.config.Configurator;
import org.apache.maven.shared.invoker.InvokerLogger;

public class Log4j2Logger implements InvokerLogger {

    private final static Logger LOGGER = LogManager.getLogger(Log4j2Logger.class);

    @Override
    public void debug(String message) {
        LOGGER.debug(message);
    }

    @Override
    public void debug(String message, Throwable throwable) {
        LOGGER.debug(message, throwable);
    }

    @Override
    public boolean isDebugEnabled() {
        return LOGGER.isDebugEnabled();
    }

    @Override
    public void info(String message) {
        LOGGER.info(message);
    }

    @Override
    public void info(String message, Throwable throwable) {
        LOGGER.info(message, throwable);
    }

    @Override
    public boolean isInfoEnabled() {
        return LOGGER.isInfoEnabled();
    }

    @Override
    public void warn(String message) {
        LOGGER.warn(message);
    }

    @Override
    public void warn(String message, Throwable throwable) {
        LOGGER.warn(message, throwable);
    }

    @Override
    public boolean isWarnEnabled() {
        return LOGGER.isWarnEnabled();
    }

    @Override
    public void error(String message) {
        LOGGER.error(message);
    }

    @Override
    public void error(String message, Throwable throwable) {
        LOGGER.error(message, throwable);
    }

    @Override
    public boolean isErrorEnabled() {
        return LOGGER.isErrorEnabled();
    }

    @Override
    public void fatalError(String message) {
        LOGGER.fatal(message);
    }

    @Override
    public void fatalError(String message, Throwable throwable) {
        LOGGER.fatal(message, throwable);
    }

    @Override
    public boolean isFatalErrorEnabled() {
        return LOGGER.isFatalEnabled();
    }

    @Override
    public void setThreshold(int threshold) {
        switch (threshold) {
            case InvokerLogger.DEBUG: {
                Configurator.setLevel(LOGGER.getName(), Level.DEBUG);
            }
            case InvokerLogger.INFO: {
                Configurator.setLevel(LOGGER.getName(), Level.INFO);
            }
            case InvokerLogger.WARN: {
                Configurator.setLevel(LOGGER.getName(), Level.WARN);
            }
            case InvokerLogger.ERROR: {
                Configurator.setLevel(LOGGER.getName(), Level.ERROR);
            }
            case InvokerLogger.FATAL: {
                Configurator.setLevel(LOGGER.getName(), Level.FATAL);
            }
            default: throw new RuntimeException("Unknown threshold");
        }
    }

    @Override
    public int getThreshold() {
        switch (LOGGER.getLevel().getStandardLevel()) {
            case OFF:
                return InvokerLogger.FATAL;
            case FATAL:
                return InvokerLogger.FATAL;
            case ERROR:
                return InvokerLogger.ERROR;
            case WARN:
                return InvokerLogger.WARN;
            case INFO:
                return InvokerLogger.INFO;
            case DEBUG:
                return InvokerLogger.DEBUG;
            case TRACE:
                return InvokerLogger.DEBUG;
            case ALL:
                return InvokerLogger.DEBUG;
            default:
                throw new IllegalStateException("Unexpected value: " + LOGGER.getLevel());
        }
    }
}
