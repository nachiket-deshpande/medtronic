global class scheduleSalesPlanCreate implements Schedulable {
    global void execute(SchedulableContext sc) {
        batchCreateSalesPlans b = new batchCreateSalesPlans();
        database.executebatch(b);
    }
}