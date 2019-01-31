-- SGA HISTORIC
CREATE OR REPLACE TRIGGER add_to_SGA_HIST
AFTER UPDATE ON "MONITOR"."SGA" FOR EACH ROW
BEGIN
    INSERT INTO "MONITOR"."SGA_HIST"
        ("name","total","timestamp")
    VALUES
        (:OLD."name",:OLD."total",:OLD."timestamp");
END;

-- PGA HISTORIC
CREATE OR REPLACE TRIGGER add_to_PGA_HIST
AFTER UPDATE ON "MONITOR"."PGA" FOR EACH ROW
BEGIN
    INSERT INTO "MONITOR"."PGA_HIST"
        ("name","usedPga","timestamp")
    VALUES
        (:OLD."name",:OLD."usedPga",:OLD."timestamp");
END;

-- CPU HISTORIC
CREATE OR REPLACE TRIGGER add_to_CPU_HIST
AFTER UPDATE ON "MONITOR"."CPU" FOR EACH ROW
BEGIN
    INSERT INTO "MONITOR"."CPU_HIST"
        ("username","cpuUsage","timestamp")
    VALUES
        (:OLD."username",:OLD."cpuUsage",:OLD."timestamp");
END;
